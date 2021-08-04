require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:posts) }
  it { should have_many(:comments) }
  it { should respond_to :name }
  it { should respond_to :email }
  it { should respond_to :password }
  it { should validate_uniqueness_of(:email).case_insensitive }
end
