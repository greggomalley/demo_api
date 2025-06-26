FactoryBot.define do
  factory :lead do
    sequence(:email) { |n| "lead#{n}@example.com" }
    sequence(:name) { |n| "Lead #{n}" }
    sequence(:message) { |n| "Message #{n}" }
    user { nil }
  end
end