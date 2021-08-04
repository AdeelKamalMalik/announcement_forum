FactoryBot.define do
  factory :post do
    user { create :user }
    content { Faker::Lorem.paragraph }

    trait :with_comments do
      transient do
        total { 10 }
      end
      after(:create) do |post, evaluator|
        create_list :comment, evaluator.total, user: post.user, post: post
      end
    end
  end
end
