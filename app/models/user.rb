class User < ActiveRecord::Base
  store :metadata, accessors: [ :profile_image_url, :followers_count, :favourites_count ], coder: JSON

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/
  extend FriendlyId
  friendly_id :username, use: :slugged
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update
  
  has_many :followers, dependent: :delete_all
  has_many :unfollowers, dependent: :delete_all

  has_one :identity, dependent: :delete

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    attrs = {
      name: auth.extra.raw_info.name,
      username: auth.info.nickname || auth.uid,
      description: auth.info.description,
      access_token: auth.credentials.token,
      access_token_secret: auth.credentials.secret,
      password: Devise.friendly_token[0,20],
      profile_image_url: auth.extra.raw_info.profile_image_url,
      followers_count: auth.extra.raw_info.followers_count,
      favourites_count: auth.extra.raw_info.favourites_count
    }

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(email: email).first if email

      # Create the user if it's a new registration
      if user.nil?
        attrs.merge!(email: email || "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com")
        user = User.new(attrs)
        user.save!
      end
    else
      user.update_attributes(attrs)
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end
end