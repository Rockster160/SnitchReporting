class CreateSnitchReportingSnitchReports < ActiveRecord::Migration[5.2]
  def change
    create_table :snitch_reporting_snitch_reports do |t|
      t.datetime :first_occurrence_at
      t.datetime :last_occurrence_at
      t.integer  :occurrences_count

      t.string   :title
      t.string   :slug
      t.string   :log_level
      t.integer  :severity
      t.text     :source
      t.text     :custom_details

      t.datetime :resolved_at
      # t.bigint   :resolved_by_id

      t.datetime :ignored_at
      # t.bigint   :ignored_by_id

      # t.bigint   :assigned_to_id

      t.timestamps
    end
  end
end
