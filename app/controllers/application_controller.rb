class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  
  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'complete'

    # Redirect to the 'complete' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_verified?
      redirect_to complete_users_path(current_user)
    end
  end
end
