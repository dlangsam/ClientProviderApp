FactoryBot.define do
  factory :provider do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
  end
end
