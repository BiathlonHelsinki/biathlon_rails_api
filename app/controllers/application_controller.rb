class ApplicationController < ActionController::API
  include ::ActionController::Cookies
  include CanCan::ControllerAdditions
  
  acts_as_token_authentication_handler_for User, fallback: :none, fallback_to_devise: false
  acts_as_token_authentication_handler_for Hardware, fallback: :none, fallback_to_devise: false
  # before_action :authenticate_user!
  
  # protect_from_forgery with: :null_session
  #
  #
  # before_action :destroy_session
  #
  # def destroy_session
  #   request.session_options[:skip] = true
  # end
  #
  # private
  #
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authenticate_admin
    if current_user.has_role?(:admin)
      return true
    else
      render json: {error: 'access denied!'}, status: 401
    end
  end
  
  def not_found
    render json: {error: 'record not found'}, status: 404
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    render json: {error: 'access denied!'}, status: 401
  end
  
end
