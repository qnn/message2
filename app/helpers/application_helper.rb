module ApplicationHelper

  def current?(path)
    "link" + (current_page?(path) ? " current" : "")
  end

end
