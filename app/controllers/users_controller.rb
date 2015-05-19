class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :complete]
  before_filter :ensure_signup_complete, only: [:new, :create, :update, :destroy]

  # GET /:username.:format
  def show
    @unfollowers = current_user.unfollowers.where(updated: 1)
  end

  # GET /:username/unfollowers.:format
  def unfollowers
    @unfollowers = current_user.unfollowers.where(updated: 1)
    if @unfollowers.empty?
      respond_to do |format|
        format.html { redirect_to current_user }
        format.json { head :no_content }
      end
    end
  end

  # PATCH/PUT /:username.:format
  def update
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user == current_user ? @user : current_user, :bypass => true)
        format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET/PATCH /:username/complete
  def complete
    if request.patch? && params[:user]
      if @user.update(user_params)
        SyncWorker.perform_async(current_user.id)
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  # DELETE /:id.:format
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    accessible = [:name, :email, :username]
    accessible << [:password, :password_confirmation] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
  end
end