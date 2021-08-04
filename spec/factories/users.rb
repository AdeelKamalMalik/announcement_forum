FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }

    trait :with_posts do
      transient do
        total { 10 }
      end
      after(:create) do |user, evaluator|
        create_list :post, evaluator.total, user: user
      end
    end
  end
end
