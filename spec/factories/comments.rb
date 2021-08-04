FactoryBot.define do
  factory :comment do
    user { create :user }
    post { create :post }
    content { 'TESTING COMMENT' }
  end
end
