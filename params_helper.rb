module ParamsHelper
  def sort_order
    params[:order] == "desc" ? "desc" : "asc"
  end

  def toggled_sort_order
    params[:order] == "desc" ? "asc" : "desc"
  end

  def sortable(link_text, param_string, options={})
    if param_string.nil?
      return link_to link_text.html_safe, options[:additional_params] || {}, class: "sortable #{options[:class]}" # rubocop:disable Rails/OutputSafety - We're certain this is safe because we're in control of all of the elements.
    end
    if params[:sort] == param_string
      sorted_class = "sorted sortable-#{toggled_sort_order}"
      default_order = toggled_sort_order
    end

    additional_params = options[:additional_params] || {}
    additional_params = additional_params.permit!.to_h if additional_params.is_a?(ActionController::Parameters)
    # rubocop:disable Rails/OutputSafety - We're certain this is safe because we're in control of all of the elements.
    link_html = "#{link_text}<div class=\"sortable-arrows\">#{svg('icons/UpChevron.svg', class: 'desc')}#{svg('icons/DownChevron.svg', class: 'asc')}</div>".html_safe
    # rubocop:enable Rails/OutputSafety
    link_to link_html, { sort: param_string, order: default_order || "desc" }.reverse_merge(additional_params), class: "sortable #{sorted_class} #{options[:class]}"
  end
end
