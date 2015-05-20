class Users::SessionsController < Devise::SessionsController
  def new
    redirect_to root_url
  end

  def destroy
    super
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
