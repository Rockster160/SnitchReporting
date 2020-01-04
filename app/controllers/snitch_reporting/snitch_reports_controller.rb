require_dependency "snitch_reporting/application_controller"

class ::SnitchReporting::SnitchReportsController < ApplicationController
  include ::SnitchReporting::ParamsHelper
  helper ::SnitchReporting::SnitchReportHelper

  layout "application"

    def index
      @snitch_reports = ::SnitchReporting::SnitchReport.order(created_at: :desc)

      # set_report_preferences
      # filter_reports
      # sort_reports
    end

    def show
      @report = ::SnitchReporting::SnitchReport.find(params[:id])
      @occurrence = @report.occurrences.last
  #     # @occurrences = @snitch_report.occurrences.order(created_at: :desc).page(params[:page]).per(params[:per])
  #     # @formatted_occurrence_data = @occurrences.staggered_occurrence_data
  #     # @comments = @snitch_report.comments.order(created_at: :desc)
    end
  #
  #   def update
  #     update_report_for(:resolved)
  #     update_report_for(:ignored)
  #
  #     @snitch_report.update(report_params) if params[:snitch_report].present?
  #
  #     respond_to do |format|
  #       format.html do
  #         if true_param?(:redirect_to_report)
  #           redirect_to @snitch_report
  #         else
  #           redirect_back fallback_location: snitch_reports_path
  #         end
  #       end
  #       format.json
  #     end
  #   end
  #
  #   def comment
  #     if @snitch_report.comments.create(comment_params.merge(author: current_credential).merge(params.permit(:resolved, :ignored)))
  #       update_report_for(:resolved, comment: false)
  #       update_report_for(:ignored, comment: false)
  #
  #       redirect_to snitch_report_path(@snitch_report)
  #     else
  #       redirect_to snitch_report_path(@snitch_report), alert: "Failed to comment. Please try again."
  #     end
  #   end
  #
  #   private
  #
  #   def current_snitch_report
  #     @snitch_report = SnitchReporting::SnitchReport.find(params[:id])
  #   end
  #
  #   def update_report_for(status, comment: true)
  #     raise "Value not allowed: #{status}" unless status.in?([:resolved, :ignored])
  #
  #     if true_param?(status)
  #       @snitch_report.update("#{status}_at": Time.current, "#{status}_by": current_credential)
  #       # @snitch_report.comments.create(author: current_credential, message: ">>> Marked as #{status} <<<", skip_notify: true, status => true) if comment
  #     elsif params[status].present?
  #       # @snitch_report.comments.create(author: current_credential, message: ">>> Marked as un#{status} <<<", skip_notify: true, status => false) if comment
  #       @snitch_report.update("#{status}_at": nil, "#{status}_by": nil)
  #     end
  #   end
  #
  #   def report_params
  #     params.require(:snitch_report).permit(
  #       :source,
  #       :severity,
  #       :assigned_to_id,
  #       :title,
  #       :custom_details
  #     )
  #   end
  #
  #   def comment_params
  #     params.require(:snitch_comment).permit(:message)
  #   end
  #
  #   def set_report_preferences
  #     @report_preferences = begin
  #       preferences = JSON.parse(session[:report_preferences].presence || "{}").symbolize_keys
  #
  #       available_preferences = [:level_tags, :severity_tags, :source_tags, :resolved, :ignored]
  #       available_preferences.each do |pref_key|
  #         pref_val = params[pref_key]
  #         preferences[pref_key] = pref_val if pref_val.present?
  #         preferences.delete(pref_key) if pref_val == "all"
  #       end
  #
  #       session[:report_preferences] = preferences.to_json
  #       preferences
  #     end
  #   end
  #
  #   def filter_reports
  #     @snitch_reports = @snitch_reports.search(@report_preferences[:by_fuzzy_text]) if @report_preferences[:by_fuzzy_text].present?
  #
  #     @snitch_reports = @snitch_reports.by_level(@report_preferences[:level_tags]) if @report_preferences[:level_tags].present?
  #     @snitch_reports = @snitch_reports.by_severity(@report_preferences[:severity_tags]) if @report_preferences[:severity_tags].present?
  #     @snitch_reports = @snitch_reports.by_source(@report_preferences[:source_tags]) if @report_preferences[:source_tags].present?
  #
  #     @snitch_reports = @report_preferences[:resolved].present? && truthy?(@report_preferences[:resolved]) ? @snitch_reports.resolved : @snitch_reports.unresolved
  #     @snitch_reports = @report_preferences[:ignored].present? && truthy?(@report_preferences[:ignored]) ? @snitch_reports.ignored : @snitch_reports.unignored
  #   end
  #
  #   def sort_reports
  #     order = sort_order || "desc"
  #     @snitch_reports =
  #     case params[:sort]
  #     when "count"
  #       @snitch_reports.order("snitch_reporting_snitch_reports.occurrences_count #{order} NULLS LAST, snitch_reporting_snitch_reports.last_occurrence_at DESC NULLS LAST")
  #     when "last"
  #       @snitch_reports.order("snitch_reporting_snitch_reports.last_occurrence_at #{order} NULLS LAST")
  #     else
  #       @snitch_reports.order("snitch_reporting_snitch_reports.last_occurrence_at DESC NULLS LAST")
  #     end
  #     @snitch_reports = @snitch_reports.page(params[:page]).per(params[:per])
  #   end
end
