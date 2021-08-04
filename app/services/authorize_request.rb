class AuthorizeRequest

  def initialize(headers = {})
    @headers = headers
  end

  def call
    if headers['Authorization'].present?
      token = headers['Authorization'].split(' ').last
      if User.find_by(auth_token: token)
        decoded_auth_token = JsonWebToken.decode(token)
        user = User.find_by(id: decoded_auth_token[:user_id])
        return OpenStruct.new(success?: true, result: user) if user&.auth_token
      end
      unauthorized_error
    else
      unauthorized_error
    end
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
    unauthorized_error
  end

  private

  attr_reader :headers

  def unauthorized_error
    OpenStruct.new(success?: false, result: nil, error: I18n.t('auth.not_signed_in'))
  end

end