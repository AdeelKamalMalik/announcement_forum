class Post < ApplicationRecord
  ## validations
  validates :content, presence: true

  ## Relationships
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :user_comments, class_name: 'Comment', foreign_key: 'user_id'
end
