class User < ApplicationRecord
  DEFAULT_EXPIRY = 24.hours.from_now
  has_secure_password

  ## validations
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, :uniqueness => { :case_sensitive => false }

  ## callbacks
  before_save :assign_expiry

  ## Relationships
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  def sign_in(password)
    response = AuthenticateUser.new(email, password).call
    self.auth_token = response.token
    self.save(validate: false)
  end

  private

  def assign_expiry
    self.expiry ||= DEFAULT_EXPIRY if auth_token
  end
end
