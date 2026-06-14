FactoryBot.define do
  factory :provider_assignment do
    association :provider
    association :client
    plan { :basic }

    trait :premium do
      plan { :premium }
    end
  end
end
