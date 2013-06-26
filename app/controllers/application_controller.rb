class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    render :file => "#{::Rails.root}/public/404", :layout => false, :status => :not_found
  end

  # is_admin? is_moderator? is_user?
  User::ROLES.each do |role|
    helper_method "is_#{role}?"
    define_method "is_#{role}?" do
      return false unless current_user.present?
      current_user.role == role
    end
  end

end
