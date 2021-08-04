module Helpers
  def sign_in(user)
    token = JsonWebToken.encode(user_id: user.id)
    user.auth_token = token
    user.save(validate: false)
    user.reload
    request.headers.merge!(Authorization: user.auth_token)
  end
end