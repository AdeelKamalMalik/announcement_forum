class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: %i[sign_up sign_in]
  def sign_up
    user = User.new(sign_up_params)
    if user.save
      user.sign_in(sign_up_params[:password])
      render json: user, status: :ok
    else
      render json: { user: user, errors: user.errors }, status: :unprocessable_entity
    end
  end

  def sign_in
    response = AuthenticateUser.new(params[:email], params[:password]).call
    response.result.auth_token = response.token if response.success?
    if response.success? && response.result.save(validate: false)
      render json: response.result, status: :ok
    else
      render json: { user: nil , errors: response.errors}, status: :unauthorized
    end
  end

  def sign_out
    if current_user
      current_user.auth_token = nil
      current_user.expiry = nil
      current_user.save(validate: false)
      render json: { message: 'Sign out successfully' }
    end
  end

  private

  def sign_up_params
    params.permit(:email, :password, :password_confirmation)
  end
end
