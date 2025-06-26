class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :leads, dependent: :nullify
  has_many :user_industries, dependent: :destroy
  has_many :industries, through: :user_industries

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
