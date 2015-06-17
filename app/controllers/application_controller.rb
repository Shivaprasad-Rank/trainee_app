class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #user_signed_in?
  # current_user
  # user_session
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:provider, :uid) }
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :password, :password_confirmation, :provider, :uid
    end
  end
  
end
