module ::SnitchReporting::SnitchReportHelper
  def search_path_from_filter_string(new_params={})
    snitch_reports_path(filter_string: filter_string_from_params(new_params))
  end

  def filter_string_from_params(extra_params={})
    @filter_builder = ::SnitchReporting::Service::FilterStringBuilder.new(from_string: params[:filter_string] || session[:snitch_filter_string] || "status:unresolved")
    @filter_string = @filter_builder.to_filter_string
    @filters = @filter_builder.filters

    session[:snitch_filter_string] = @filter_string.dup
  end
end
