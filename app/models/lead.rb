class Lead < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :industry

  after_save :assign_lead

  def assign_lead
  end
end
