class RegistrationsController < Devise::RegistrationsController

  def edit
  end

  def update
    # if you are not an admin or moderator, you can't change your username or email address
    if params[:user].has_key?(:username) and params[:user].has_key?(:email)
      if current_user.present? and not %w(admin moderator).include? current_user.role
        not_found and return unless params[:user][:username] == current_user.username
        not_found and return unless params[:user][:email] == current_user.email
      end
    end
    super
  end

end
