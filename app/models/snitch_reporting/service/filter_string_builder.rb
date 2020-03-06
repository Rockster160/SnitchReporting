class ::SnitchReporting::Service::FilterStringBuilder
  attr_accessor :filter_hash, :filters, :unknown_filters

  def self.filter_sets
    {
      status: {
        default: :unresolved,
        values: [:all, :resolved, :unresolved]
      },
      # assignee: {
      #   default: :any,
      #   values: [:any, :me, :not_me, :not_assigned]
      # },
      log_level: {
        default: :any,
        values: [:any] + ::SnitchReporting::SnitchReport.log_levels.keys.map(&:to_sym)
      },
      # ignored: {
      #   default: :not_ignored,
      #   values: [:all, :ignored, :not_ignored]
      # }
    }
  end

  # extra_params.each do |param_key, param_value|
  #   param_key = param_key.to_s
  #   param_value = param_value.to_s
  #
  #   if param_value.blank?
  #     # Search pure text by itself
  #     search_strings << param_key
  #   elsif @filter_sets.keys.include?(param_key.to_s.to_sym)
  #     param_value = decode_string(secret_key, param_value)
  #     @filters[param_key.to_sym] = param_value.to_sym
  #   elsif param_key == "search"
  #     search_strings << decode_string(secret_key, param_value)
  #   elsif param_key == "tag" || param_key == "tags"
  #     tag_strings << decode_string(secret_key, param_value)
  #   else
  #     @unknown_strings << "#{param_key}:#{param_value}"
  #   end
  # end

  def filter_sets
    self.class.filter_sets
  end

  def initialize(from_string: nil, from_data: nil)
    parse_filters_from_string(from_string) if from_string.present?
  end

  def to_param
    { filter_string: to_filter_string }
  end

  def to_filter_string
    filter_strings = []
    tag_strings = []
    search_strings = []

    @filters.each do |filter_key, filter_value|
      if filter_key == :search
        search_strings += filter_value
      elsif filter_key == :tags
        tag_strings += filter_value.map { |value| filter_to_string(filter_key, filter_value) }
      elsif filter_sets.keys.include?(filter_key.to_s.to_sym)
        filter_strings << filter_to_string(filter_key, filter_value)
      else
        # No-op for now. Probably should display these somewhere?
      end
    end

    (filter_strings + tag_strings + search_strings).join(" ")
  end

  def add_filter(filter_key, filter_value)
    filter_key = filter_key.to_s.to_sym
    @filters ||= {search: [], tags: [], unknown: []}

    if filter_value.blank?
      @filters[:search] << filter_key
    elsif filter_key == :search
      @filters[:search] << filter_key
    elsif filter_key == :tags
      @filters[:tags] << {filter_key => filter_value}
    else
      @filters[filter_key] = filter_value.to_s.to_sym
    end
  end

  private

  def encode_string(str)
    @encoded_strings ||= []

    @encoded_strings << str
    "#{@parse_token}(#{@encoded_strings.length - 1})"
  end

  def decode_string(encoded_str)
    @encoded_strings ||= []

    encoded_str.gsub(/#{Regexp.escape(@parse_token)}\((\d+)\)/) do |found|
      encoded_idx = Regexp.last_match(1)

      if encoded_idx.to_i.to_s == encoded_idx
        @encoded_strings[encoded_idx.to_i]
      else
        found
      end
    end
  end

  def parse_filters_from_string(filter_string)
    @parse_token = generate_uniq_key(filter_string)
    encoded_string = extract_quoted_strings(filter_string)
    parsed_strings = group_values_without_filter(encoded_string)

    parsed_strings[:filters].each do |parsed_string|
      filter, value, * = parsed_string.split(":")

      add_filter(filter, decode_string(value))
    end
  end

  def group_values_without_filter(encoded_string)
    filter_group_hash = {
      filters: [],
      search: [],
      tags: [],
      unknown: []
    }
    encoded_string.split(" ").each_with_object(filter_group_hash) do |filter, filter_groups|
      if filter.include?(":")
        filter_groups[:filters] << filter
      else
        filter_groups[:search] << filter
      end
    end
  end

  def filter_to_string(filter, value)
    filter = "\"#{filter}\"" if filter.to_s.include?(" ")
    value = "\"#{value}\"" if value.to_s.include?(" ")
    [filter.presence, value.presence].compact.join(":")
  end

  def extract_quoted_strings(filter_string)
    filter_string.gsub(/\"(.*?)\"/) do |found|
      encode_string(secret_key, Regexp.last_match(1))
    end
  end

  def generate_uniq_key(filter_string)
    loop do
      token = SecureRandom.hex(10)
      break token unless filter_string.to_s.include?(token)
    end
  end
end
