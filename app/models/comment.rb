class Comment < ApplicationRecord
  ## validations
  validates :content, presence: true

  ## Relationships
  belongs_to :post
  belongs_to :user

  ## Scopes
  scope :of_post, -> (post_id) { where(post_id: post_id) }
end
