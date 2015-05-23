# Redirect a user to oauth flow if not signed in
class UserNotSignedIn < Devise::FailureApp
  def redirect_url
    user_omniauth_authorize_path(:dropbox_oauth2)
  end

  def redirect
    store_location!
    redirect_to redirect_url
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
