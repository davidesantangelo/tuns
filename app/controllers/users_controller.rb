# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy complete]
  before_action :ensure_signup_complete, only: %i[new create update destroy]

  # GET /:username.:format
  def show
    @unfollowers = @user.unfollowers.updated.paginate(page: params[:page])
  end

  # PATCH/PUT /:username.:format
  def update
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user == current_user ? @user : current_user, bypass: true)
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
        # load all followers uid
        SyncWorker.perform_async(current_user.id)
        sign_in(@user, bypass: true)
        redirect_to @user, notice: 'Your profile was successfully activated.'
      else
        flash[:error] = "Unable to complete signup due: #{@user.errors.full_messages.to_sentence}"
      end
    end
  end

  # DELETE /:username.:format
  def destroy
    reset_session
    DeleteUserWorker.perform_async(@user.id)
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Your account was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # GET /loadmore
  def loadmore
    @stop_loading = false
    @unfollowers = current_user.unfollowers.updated.paginate(page: params[:page])
    if @unfollowers.last && current_user.unfollowers.updated.last.id == @unfollowers.last.id
      @stop_loading = true
    end
  end

  # GET /loadstats
  def loadstats
    # TO DO
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    accessible = %i[name email username description name notification]
    accessible << %i[password password_confirmation] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
  end
end
