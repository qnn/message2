class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    render :file => "#{::Rails.root}/public/404", :layout => false, :status => :not_found
  end
end
