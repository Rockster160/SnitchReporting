# belongs_to :snitch_report
# string :http_method
# string :url
# text :user_agent
# text :backtrace
# text :context
# text :params
# text :headers

class SnitchReporting::SnitchOccurrence < ApplicationRecord
  attr_accessor :always_notify, :acting_user

  belongs_to :report, class_name: "SnitchReporting::SnitchReport"

  after_create :mark_occurrence

  serialize :backtrace_data, ::SnitchReporting::Service::JSONWrapper
  serialize :backtrace,      ::SnitchReporting::Service::JSONWrapper
  serialize :context,        ::SnitchReporting::Service::JSONWrapper
  serialize :params,         ::SnitchReporting::Service::JSONWrapper
  serialize :headers,        ::SnitchReporting::Service::JSONWrapper

  # def self.staggered_occurrence_data
  #   data = {}
  #   occurrence_data_keys = all.map { |occurrence| occurrence.details.try(:keys) }.compact
  #   longest_key_array = occurrence_data_keys.max_by(&:length) # Need the longest because `zip` removes any objects longer than the initial.
  #   staggered_keys = longest_key_array&.zip(*occurrence_data_keys)&.flatten(1)&.compact&.uniq || []
  #
  #   data[:keys] = staggered_keys
  #   data[:details] = all.map do |occurrence|
  #     detail_hash = {
  #       id: occurrence.id,
  #       details: []
  #     }
  #     occurrence_details = occurrence.details
  #     data[:keys].each_with_index do |detail_key, idx|
  #       occurrence_detail = occurrence_details[detail_key]
  #       detail_hash[:details][idx] =
  #         if occurrence_detail.is_a?(Array)
  #           occurrence_detail.join("\n")
  #         else
  #           occurrence_detail.to_s
  #         end
  #     end
  #     detail_hash
  #   end
  #
  #   data
  # end
  #
  # def from_data=(details_hash)
  #   self.details = flatten_hash(details_hash)
  # end

  def backtrace=(trace_lines)
    already_traced = []
    self.backtrace_data = trace_lines.map do |trace_line|
      next unless trace_line.include?("/app/") # && trace_line.exclude?("app/models/snitch_reporting")

      joined_path = file_lines_from_backtrace(trace_line)
      next if joined_path.include?(joined_path)
      already_traced << joined_path

      file_path, line_number = joined_path.split(":", 2)
      {
        file_path: remove_project_root(file_path),
        line_number: line_number,
        snippet: snippet_for_line(trace_line)
      }
    end.compact
    super(trace_lines.map { |trace_line| remove_project_root(trace_line) })
  end

  def filtered_backtrace
    backtrace_data&.map { |data| data&.dig(:file_path) }.compact
  end

  def remove_project_root(row)
    row.gsub(Rails.root.to_s, "[PROJECT_ROOT]")
  end

  def file_lines_from_backtrace(backtrace_line)
    backtrace_line[/(\/?\w+\/?)+(\.\w+)+:?\d*/]
  end

  def snippet_for_line(backtrace_line, line_count: 5)
    file, num = backtrace_line.split(":")
    first_line_number = num.to_i
    offset_line_numbers = (line_count - 1) / 2
    line_numbers = (first_line_number - offset_line_numbers - 1)..(first_line_number + offset_line_numbers - 1)

    lines = File.open(file).read.split("\n").map.with_index { |line, idx| [line, idx + 1] }[line_numbers] rescue nil

    whitespace_count = lines.map { |line, _idx| line[/\s*/].length }.min

    lines.each_with_object({}) do |(line, idx), data|
      data[idx] = line[whitespace_count..-1]
    end
  end
  #
  # def title
  #   super.presence || "#{report.title} | Occurrence ##{id}"
  # end
  #
  # def details
  #   temp_details = super
  #
  #   temp_details.each do |detail_key, detail_val|
  #     next unless detail_val.to_s.first.in?(["[", "{"])
  #
  #     begin
  #       temp_details[detail_key] = JSON.parse(detail_val)
  #     rescue JSON::ParserError
  #       nil
  #     end
  #   end
  #
  #   temp_details
  # end

  def notify?
    always_notify || report.resolved? || report.occurrence_count == 1
  end

  private

  def mark_occurrence
    report_updates = { last_occurrence_at: Time.current, resolved_at: nil }
    report_updates[:first_occurrence_at] = Time.current if report.first_occurrence_at.nil?
    report_updates[:occurrence_count] = report.occurrence_count.to_i + 1

    report.update(report_updates)

    tracker = report.tracker_for_date
    now = Time.current
    todays_occurrences = report.occurrences.where(created_at: now.beginning_of_day..now.end_of_day)
    tracker.update(count: todays_occurrences.count + 1)
  end

  # def to_slack_attachment
  #   details ||= {}
  #   description = details[:description] || details[:error_description] || details[:error] || details[:explanation]
  #   source = report.source.to_s.titleize
  #   level = report.log_level.to_sym
  #
  #   color =
  #     case level
  #     when :debug   then "#F5F5F5"
  #     when :info    then "#209CEE"
  #     when :warn    then "#FFDD57"
  #     when :error   then "#FF945B"
  #     when :fatal   then "#FF1F35"
  #     when :unknown then "#000000"
  #     end
  #   fields = []
  #   fields << { title: "Level",       value: level,       short: true }  if level.present?
  #   fields << { title: "Source",      value: source,      short: true }  if source.present?
  #   fields << { title: "Description", value: description, short: false } if description.present?
  #
  #   {
  #     pretext: report.resolved? ? "A previously resolved #{level} level error has occurred again:" : "A new #{level} level error has occurred:",
  #     title: title,
  #     fallback: "```#{filtered_backtrace.present? ? filtered_backtrace.first(5).join("\n") : description}```",
  #     color: color,
  #     title_link: custom_url_for(:helix, :bug_report_path, report_id),
  #     text: filtered_backtrace.present? ? filtered_backtrace.first(10).join("\n") : description,
  #     fields: fields,
  #     footer: "Last occurred:",
  #     ts: created_at.to_i
  #   }
  # end
  #
  # def flatten_hash(hash_to_flatten, hash_memo={}, ancestor_key_str=nil)
  #   hash_to_flatten = hash_to_flatten[0] if hash_to_flatten.is_a?(Array) && hash_to_flatten.first.is_a?(Hash)
  #   return hash_memo.merge!(ancestor_key_str => hash_to_flatten.to_s) unless hash_to_flatten.is_a?(Hash)
  #   # If the current object is not a hash, we don't need to continue nesting, so set the current ancestor string as the final key.
  #   hash_to_flatten.each { |key, hash_values| flatten_hash(hash_values, hash_memo, [ancestor_key_str, key].compact.join(".")) }
  #   # Iterate through the hash, and pass each key as the ancestor into the current method to flatten lower level hashes.
  #   hash_memo
  #   # Return the current hash for memoization.
  # end
end
