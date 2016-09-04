class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user && @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      if is_navigational_format?
        flash[:error] = "Account for #{request.env["omniauth.auth"].try(:info).try(:email).inspect} is not authorized."
      end
      redirect_to new_user_session_path
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
