module SnitchReporting
  class SnitchReport < ApplicationRecord
    has_many :snitch_occurrences

    scope :resolved,      -> { where.not(resolved_at: nil) }
    scope :unresolved,    -> { where(resolved_at: nil) }
    scope :ignored,       -> { where.not(ignored_at: nil) }
    scope :unignored,     -> { where(ignored_at: nil) }
    scope :by_level,      ->(*level_tags) { where(log_level: level_tags) }
    scope :by_source,     ->(*sources) { where(source: sources) }
    scope :by_severity,   ->(*severity_tags) { where(severity: severities.slice(*[severity_tags].flatten.compact.map(&:to_s)).values) }

    enum severity: {
      blocking:    1,
      critical:    2,
      normal:      3,
      small:       4,
      enhancement: 5
    }

    class << self
      def debug(*args);   report(:debug,   args); end
      def info(*args);    report(:info,    args); end
      def warn(*args);    report(:warn,    args); end
      def error(*args);   report(:error,   args); end
      def fatal(*args);   report(:fatal,   args); end
      def unknown(*args); report(:unknown, args); end

      def sources
        pluck(:source).uniq
      end

      def report(log_level, *args)
        exceptions, arg_hash, arg_values = format_args(args)
        env, klass, base_exception = extract_base_variables(exceptions, arg_hash, arg_values)
        always_notify = arg_hash.delete(:always_notify)

        report_title = retrieve_report_title(base_exception, arg_hash, arg_values)
        report = retrieve_or_create_existing_report(log_level, santize_title(report_title), arg_hash)
        return SnitchReport.error("Failed to save report.", report.errors.full_messages) unless report.exists?

        report_data = gather_report_data(env, exceptions, arg_hash, arg_values)

        occurrence = report.occurrences.create(
          klass: klass,
          title: report_title,
          always_notify: always_notify,
          backtrace: trace_from_exception(base_exception),
          from_data: report_data,
          occurrence_position: report.occurrences_count.to_i + 1
        )
        return SnitchReport.error("Failed to save occurrence.", occurrence.errors.full_messages) unless occurrence.exists?
        occurrence
      rescue StandardError => ex
        env ||= {}
        SnitchReport.fatal("Failed to create bug report. (#{ex.class})", env, ex)
      end

      def format_args(args)
        args = [args].flatten.compact

        exceptions = args.select { |arg| arg.is_a?(Exception) }
        reduced_arrays = args.select { |arg| arg.is_a?(Array) }.reduce([], :concat)
        reduced_values = args.select { |arg| [Array, Exception, Hash].all? { |klass| !arg.is_a?(klass) } }
        arg_values = reduced_arrays + reduced_values

        arg_hash = (args.select { |arg| arg.is_a?(Hash) }.inject(&:merge) || {}).deep_symbolize_keys
        # This will remove duplicate keys in the case there are multiple hashes
        #   passed in for some reason. I don't foresee this being an issue, but
        #   if it ever proves to be, this is the spot to refactor.
        [exceptions, arg_hash, arg_values]
      end

      def extract_base_variables(exceptions, arg_hash, _arg_values)
        exceptions << arg_hash.delete(:exception) if arg_hash[:exception].present?
        base_exception = exceptions.first || {}
        klass = arg_hash[:klass] || arg_hash[:class]
        env = arg_hash.delete(:env) || {}

        [env, klass, base_exception]
      end

      def trace_from_exception(exception)
        trace = exception.try(:backtrace).presence
        return trace if trace.present?
        trace = caller.dup
        trace.shift until trace.first.exclude?("app/models/bug_report")
        trace
      end

      def add_critical_details_to_report_data(report_data, exceptions, _env, _arg_hash)
        return unless exceptions.any?

        base_exception = exceptions.first
        report_data[:class] = base_exception.class
        report_data[:title] = base_exception.message
      end

      def add_selective_to_report_data(report_data, _env, arg_hash)
        # report_data[:*_id] = arg_hash.delete(:*_id) if arg_hash[:*_id].present?
      end

      def extract_relevant_ivars(report_data, kontroller)
        set_user_vars_from_source(report_data, kontroller)
      end

      def set_user_vars_from_source(report_data, source)
        user_vars = source.try(:instance_variables)&.select { |ivar_key| ivar_key.to_s.starts_with?("@current_") } || []
        user_vars.each do |user_var|
          begin
            ivar = source.instance_variable_get(user_var)
            next if ivar.blank?

            report_data[user_var] = get_details_from_ivar(ivar)
          rescue StandardError => ex
            report_data[user_var] = "!-- Failed to retrieve data from user #{user_var}: #{ivar.try(:class).try(:name)} (#{ex.class}) --!"
          end
        end
      end

      def get_details_from_ivar(ivar)
        return ivar.class.name if ivar.class.name.include?("Abilit")
        case ivar.class.name
        when "String", "Array", "Hash" then ivar
        when "ActionController::Parameters" then ivar.to_json
        when "ActiveRecord::Relation"
          "#{ivar.klass} ids: [#{ivar.pluck(:id).join(', ')}]"
        else
          ivar.try(:to_data) || ivar.try(:to_json) || ivar.to_s.presence
        end
      end

      def add_controller_data_to_report(report_data, env)
        kontroller = env&.dig(:"action_controller.instance")
        return if kontroller.blank?

        extract_relevant_ivars(report_data, kontroller)

        kontroller.instance_variables.each do |ivar_key|
          begin
            next if ivar_key.to_s.starts_with?("@current_") # Already extracted these in the above method
            next if ivar_key.in?(ignored_kontroller_ivars)

            ivar = kontroller.instance_variable_get(ivar_key)
            next if ivar.blank?

            report_data[ivar_key] = get_details_from_ivar(ivar)
          rescue StandardError => ex
            report_data[ivar_key] = "!-- Failed to retrieve data from variable #{ivar_key}: #{ivar.try(:class).try(:name)} (#{ex.class}) --!"
          end
        end
      end

      def retrieve_report_title(exception, arg_hash, arg_values)
        report_title = arg_hash[:title].presence
        report_title ||= [exception.class, exception.message].join(": ") if exception.present?
        report_title ||= [(arg_hash[:klass] || arg_hash[:class]).presence, arg_values.first].compact.join(": ").presence
        report_title ||= trace_from_exception(exception).find { |row| row.include?("/app/") }
        report_title
      end

      def add_leftover_objects_to_report_data(report_data, exceptions, arg_hash, arg_values)
        report_data[:exceptions] = exceptions.map { |ex| "#{ex.try(:class)}: #{ex.try(:message)}" } if exceptions.present?
        report_data.merge!(arg_hash)
        report_data[:details] = arg_values if arg_values.present?
      end

      def add_sanitized_env_information_to_report_data(report_data, env)
        report_data[:env] = env.slice(*relevant_env_keys) if env.present?
      end

      def santize_title(report_title)
        regex_find_numbers_and_words_with_numbers = /\w*\d[\d\w]*/
        # We remove all numbers and words that have numbers in them so that we can
        #   more easily group similar errors together, but often times errors have
        #   unique ids, so we strip those out.
        report_title.to_s.gsub(regex_find_numbers_and_words_with_numbers, "").presence
      end

      def retrieve_or_create_existing_report(log_level, sanitized_title, arg_hash)
        source = arg_hash.delete(:source) || :web
        report = find_by(log_level: log_level, source: source, slug: sanitized_title) if sanitized_title.present?
        # Not using find or create because the slug might be `nil`- in these
        #   cases, we want to create a new report so that we don't falsely group
        #   unrelated errors together.
        report ||= create(log_level: log_level, source: source, slug: sanitized_title.presence)

        severity = arg_hash.delete(:severity)
        report.update(severity: severity) if severity.present?

        report
      end

      def gather_report_data(env, exceptions, arg_hash, arg_values)
        report_data = {}

        add_critical_details_to_report_data(report_data, exceptions, env, arg_hash)
        add_selective_to_report_data(report_data, env, arg_hash)
        add_controller_data_to_report(report_data, env)
        add_leftover_objects_to_report_data(report_data, exceptions, arg_hash, arg_values)
        add_sanitized_env_information_to_report_data(report_data, env)

        report_data
      end

      def ignored_kontroller_ivars
        [
          :@_request,
          :@_response,
          :@_response,
          :@_lookup_context,
          :@_authorized,
          :@_main_app,
          :@_view_renderer,
          :@_view_context_class,
          :@_db_runtime,
          :@marked_for_same_origin_verification
        ]
      end

      def relevant_env_keys
        [
          :REQUEST_URI,
          :REQUEST_METHOD,
          :HTTP_REFERER,
          :HTTP_USER_AGENT,
          :PATH_INFO,
          :HTTP_CONNECTION,
          :REMOTE_USER,
          :SERVER_NAME,
          :QUERY_STRING,
          :REMOTE_HOST,
          :SERVER_PORT,
          :HTTP_ACCEPT_ENCODING,
          :HTTP_USER_AGENT,
          :SERVER_PROTOCOL,
          :HTTP_CACHE_CONTROL,
          :HTTP_ACCEPT_LANGUAGE,
          :HTTP_HOST,
          :REMOTE_ADDR,
          :SERVER_SOFTWARE,
          :HTTP_KEEP_ALIVE,
          :HTTP_REFERER,
          :HTTP_ACCEPT_CHARSET,
          :GATEWAY_INTERFACE,
          :HTTP_ACCEPT,
          :HTTP_COOKIE
        ]
      end
    end

    def resolved?; resolved_at?; end
    def ignored?; ignored_at?; end

    def title
      super.presence || slug.presence || "Report ##{id}"
    end

    def timeago
      "Not implemented"
      # timeago_in_words(last_occurrence_at)
    end

    def slack_channel
      "Not implemented"
      # "error-reporting"
    end
  end
end
