FactoryBot.define do
  factory(:user_industry, class: UserIndustry) do
    sequence(:ordering) { |n| n }
  end
end