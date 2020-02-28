module ::SnitchReporting::SnitchReportHelper
  def search_path_from_filter_string(new_params={})
    snitch_reports_path(filter_string: filter_string_from_params(new_params))
  end

  def filter_string_from_params(extra_params={})
    @filter_string = params[:filter_string] || session[:snitch_filter_string] || "status:unresolved"
    @unknown_strings = []
    @filters = {}

    secret_key = loop do
      token = SecureRandom.hex(10)
      break token unless @filter_string.include?(token)
    end

    temp_filter_string = @filter_string.gsub(/\"(.*?)\"/) do |found|
      encode_string(secret_key, Regexp.last_match(1))
    end

    search_strings = []
    tag_strings = []
    filter_strings = temp_filter_string.split(" ").select do |filter_string|
      search_strings << filter_string unless filter_string.include?(":")
      filter_string.include?(":")
    end

    filter_strings.each do |filter_string|
      filter, value, * = filter_string.split(":")
      if value.blank?
        # Search pure text by itself
        search_strings << filter
      elsif @filter_sets.keys.include?(filter.to_s.to_sym)
        value = decode_string(secret_key, value)
        @filters[filter.to_sym] = value.to_sym
      elsif filter == "search"
        search_strings << decode_string(secret_key, value)
      elsif filter == "tag" || filter == "tags"
        tag_strings << decode_string(secret_key, value)
      else
        @unknown_strings << filter_string
      end
    end

    extra_params.each do |param_key, param_value|
      param_key = param_key.to_s
      param_value = param_value.to_s

      if param_value.blank?
        # Search pure text by itself
        search_strings << param_key
      elsif @filter_sets.keys.include?(param_key.to_s.to_sym)
        param_value = decode_string(secret_key, param_value)
        @filters[param_key.to_sym] = param_value.to_sym
      elsif param_key == "search"
        search_strings << decode_string(secret_key, param_value)
      elsif param_key == "tag" || param_key == "tags"
        tag_strings << decode_string(secret_key, param_value)
      else
        @unknown_strings << "#{param_key}:#{param_value}"
      end
    end

    @filters[:search] = "\"#{search_strings.join(' ')}\"" if search_strings.any?
    @filters[:tag] = tag_strings

    new_filter_strings = @filters.each_with_object([]) do |(filter_string, filter_value), filter_array|
      next unless filter_value.present?
      if filter_value.is_a?(Array)
        filter_value.each do |filter_value_i|
          filter_array << "#{filter_string}:#{filter_value_i}"
        end
      else
        filter_array << "#{filter_string}:#{filter_value}"
      end
    end

    @filter_string = new_filter_strings.join(" ")
    session[:snitch_filter_string] = @filter_string.dup
  end

  def encode_string(token, str)
    @interpolated_strings ||= []

    @interpolated_strings << str
    "#{token}(#{@interpolated_strings.length})"
  end

  def decode_string(token, encoded_str)
    @interpolated_strings ||= []

    encoded_str.gsub(/(\w+)\((\d+)\)/) do |found|
      token = Regexp.last_match(1)
      idx = Regexp.last_match(2)

      if idx.to_i.to_s == idx
        @interpolated_strings[idx.to_i - 1]
      else
        found
      end
    end
  end
end
