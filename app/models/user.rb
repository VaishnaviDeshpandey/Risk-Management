class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :portfolios, dependent: :destroy
  has_many :custom_assets, through: :portfolios

  # Define available roles
  ROLES = %w[admin trader investor].freeze

  validates :username, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role" }

  # Methods for checking roles
  def admin?
    role == 'admin'
  end

  def trader?
    role == 'trader'
  end

  def investor?
    role == 'investor'
  end     
  
  def self.ransackable_attributes(auth_object = nil)
    %w[id email username created_at updated_at role]
  end
       
end
