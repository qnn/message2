class ApplicationController < ActionController::Base
  protect_from_forgery

  LOCALES = { en: "English", zh_CN: "中文" }

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

  before_filter :set_locale
 
  def set_locale
    if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      cookies['locale'] = { :value => params[:locale], :expires => 1.year.from_now }
      I18n.locale = params[:locale].to_sym
    elsif cookies['locale'] && I18n.available_locales.include?(cookies['locale'].to_sym)
      I18n.locale = cookies['locale'].to_sym
    end
  end

end

class String
  def gender_name
    I18n::translate "gender.#{self}"
  end

  def role_name
    I18n::translate "role.#{self}"
  end
end
