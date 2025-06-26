FactoryBot.define do
  factory :industry do
    sequence(:name) { |n| "Industry #{n}" }

    factory :tech_industry do
      name { "Technology" }
    end

    factory :finance_industry do
      name { "Finance" }
    end

    factory :healthcare_industry do
      name { "Healthcare" }
    end
  end
end