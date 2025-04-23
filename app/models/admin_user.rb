class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  # Add this method to allow Ransack searches on specific attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at] # Add only the attributes you want to be searchable
  end       
end
