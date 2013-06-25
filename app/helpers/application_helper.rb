module ApplicationHelper

  def current?(path)
    "link" + (current_page?(path) ? " current" : "")
  end

end

class PaginationListLinkRenderer < WillPaginate::ActionView::LinkRenderer
  protected
  
  def html_container(html)
    tag :div, html, container_attributes
  end

  def page_number(page)
    link page, page, :rel => rel_value(page), :class => ('current' if page == current_page)
  end

  def previous_or_next_page(page, text, classname)
    link text, page || 'javascript:;', :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
  end
end
