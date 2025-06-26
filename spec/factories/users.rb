FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }

    trait :with_tech_industry do
      after(:create) do |user|
        industry = Industry.find_or_create_by(name: "Technology")
        create(:user_industry, user:, industry:)
      end
    end

    trait :with_finance_industry do
      after(:create) do |user|
        industry = Industry.find_or_create_by(name: "Finance")
        create(:user_industry, user:, industry:)
      end
    end

    trait :with_healthcare_industry do
      after(:create) do |user|
        industry = Industry.find_or_create_by(name: "Healthcare")
        create(:user_industry, user:, industry:)
      end
    end
  end
end