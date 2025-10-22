class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :health_logs, dependent: :destroy
  has_many :activity_logs, through: :health_logs
  has_many :custom_fields, dependent: :destroy
end
