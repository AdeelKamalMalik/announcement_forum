class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  private
  def authenticate_request
    authentication = AuthorizeRequest.new(request.headers).call
     @current_user = authentication.result if authentication.success?
    render json: { error: authentication.error }, status: 401 unless authentication.success?
  end
end
