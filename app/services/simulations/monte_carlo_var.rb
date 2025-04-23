# app/services/simulations/monte_carlo_var.rb

module Simulations
  class MonteCarloVar
    attr_reader :prices, :simulations, :days, :confidence

    def initialize(prices:, simulations:, days:, confidence:)
      @prices = prices.compact.map(&:to_f).reject { |p| p <= 0 }
      @simulations = simulations
      @days = days
      @confidence = confidence
    end

    def run
      if prices.empty? || prices.uniq.size < 2
        Rails.logger.warn("[MonteCarloVar] Insufficient or non-variant price data")
        return { var: 0.0, cvar: 0.0 }
      end

      price_changes = simulate_price_changes

      Rails.logger.info("[MonteCarloVar] Simulated changes sample: #{price_changes[0..5].inspect}")
      Rails.logger.info("[MonteCarloVar] NaNs: #{price_changes.count(&:nan?)}, Nils: #{price_changes.count(&:nil?)}")

      {
        var: calculate_var(price_changes),
        cvar: calculate_cvar(price_changes)
      }
    end

    private

    def simulate_price_changes
      mean = mean_daily_return
      std_dev = standard_deviation

      Rails.logger.info("[MonteCarloVar] Mean return: #{mean.round(6)}, StdDev: #{std_dev.round(6)}")

      Array.new(simulations) do
        path = simulate_price_path(prices.last, mean, std_dev, days)
        next if path.empty?

        change = path.last - path.first
        Rails.logger.warn("⚠️ Simulation result was NaN or nil") if change.nil? || change.nan?
        change
      end.compact.reject(&:nan?)
    end

    def simulate_price_path(start_price, mean_return, stddev, days)
      return [] if [start_price, mean_return, stddev].any?(&:nil?)

      price_path = [start_price]
      current_price = start_price

      days.times do
        drift = mean_return - 0.5 * stddev**2
        shock = stddev * rand_normal
        next_price = current_price * Math.exp(drift + shock)
        break unless next_price.finite? && !next_price.nan?

        price_path << next_price
        current_price = next_price
      end

      price_path.size < 2 ? [] : price_path
    end

    def rand_normal
      u1, u2 = rand, rand
      Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math::PI * u2)
    rescue => e
      Rails.logger.error("⚠️ rand_normal error: #{e.message}")
      0.0
    end

    def log_returns
      @log_returns ||= prices.each_cons(2).map do |a, b|
        next if a <= 0 || b <= 0
        Math.log(b / a)
      end.compact.reject(&:nan?)
    end

    def mean_daily_return
      return 0.0 if log_returns.empty?
      log_returns.sum / log_returns.size
    end

    def standard_deviation
      return 0.0 if log_returns.empty?
      mean = mean_daily_return
      Math.sqrt(log_returns.sum { |r| (r - mean)**2 } / log_returns.size)
    end

    def calculate_var(changes)
      return 0.0 if changes.empty?
      sorted_losses = changes.map(&:-@).sort
      index = (sorted_losses.size * (1 - confidence)).floor
      sorted_losses[index] || 0.0
    end

    def calculate_cvar(changes)
      return 0.0 if changes.empty?
      sorted_losses = changes.map(&:-@).sort
      threshold_index = (sorted_losses.size * (1 - confidence)).floor
      tail_losses = sorted_losses[0..threshold_index]
      tail_losses.empty? ? 0.0 : tail_losses.sum / tail_losses.size
    end
  end
end
