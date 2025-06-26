class Industry < ApplicationRecord
  has_many :user_industries
  has_many :users, through: :user_industries
  has_many :leads
end
