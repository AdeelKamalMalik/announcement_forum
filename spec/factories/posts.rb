FactoryBot.define do
  factory :post do
    user { create :user }
    content { 'TESTING CONTENT' }
  end
end
