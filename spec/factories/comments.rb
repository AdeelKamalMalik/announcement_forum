FactoryBot.define do
  factory :comment do
    user { create :user }
    post { create :post }
    content { Faker::Lorem.paragraph }
  end
end
