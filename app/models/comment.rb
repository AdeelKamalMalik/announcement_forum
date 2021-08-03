class Comment < ApplicationRecord
  ## validations
  validates :content, presence: true

  ## Relationships
  belongs_to :post
end
