FactoryBot.define do
  factory :user do
    name { "MyString" }
    email { "TESTING@MAIL.COM" }
    password { "password" }
    password_confirmation { "password" }
  end
end
