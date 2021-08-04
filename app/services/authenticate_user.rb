class AuthenticateUser

  def initialize(email, password)
    @email = email
    @password = password
    @auth_error = []
  end

  def call
    if user && auth_error.empty?
      OpenStruct.new(success?: true, result: user, token: JsonWebToken.encode(user_id: user.id))
    else
      OpenStruct.new(success?: false, result: nil, errors: auth_error )
    end
  end

  private

  attr_accessor :email, :password, :auth_error

  def user
    user = User.find_by_email(email)
    return user if user && user.authenticate(password)

    @auth_error = I18n.t('auth.invalid_credentials')
    nil
  end
end