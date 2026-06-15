FactoryBot.define do
  factory :note do
    association :client
    content { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end
