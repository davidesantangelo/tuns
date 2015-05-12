class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :complete]
  before_action :load_config
  before_action :fetch_followers, only: [:show]
  before_filter :ensure_signup_complete, only: [:new, :create, :update, :destroy]


  # GET /users/:id.:format
  def show
    current_user.followers
  end

  # GET /users/:id/edit
  def edit
  end

  # PATCH/PUT /users/:id.:format
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

  # GET/PATCH /users/:id/complete
  def complete
    if request.patch? && params[:user]
      if @user.update(user_params)
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  # DELETE /users/:id.:format
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end
  
  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      accessible = [ :name, :email, :username ]
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      params.require(:user).permit(accessible)
    end

    def load_config
      twitter_config =  YAML.load_file('config/twitter.yml')[Rails.env]
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = twitter_config['consumer_key']
        config.consumer_secret     = twitter_config['consumer_secret']
        config.access_token        = current_user.access_token
        config.access_token_secret = current_user.access_token_secret
      end
    end

    def fetch_followers
      cursor = "-1"
      while cursor != 0 and valid_request? do
        begin
          limited_followers = @twitter_client.followers(current_user.username, {cursor: cursor} )
          Request.create(user_id: current_user.id, resource: 'followers')
          limited_followers.attrs[:users].each do |follower|
            Follower.where(user_id: current_user.id, username: follower[:screen_name]).first_or_create
          end
          cursor = limited_followers.attrs[:next_cursor]
        rescue Twitter::Error::TooManyRequests => error
          sleep error.rate_limit.reset_in + 1
          retry
        end
      end
    end

    def valid_request?
      # 15 requests per window per leveraged access token https://dev.twitter.com/rest/public/rate-limiting
      current_user.requests.size <= 15 or (Time.now.to_i - current_user.requests.last.created_at.to_i) > 900
    end
end