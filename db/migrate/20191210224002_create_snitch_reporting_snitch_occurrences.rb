class CreateSnitchReportingSnitchOccurrences < ActiveRecord::Migration[5.2]
  def change
    create_table :snitch_reporting_snitch_occurrences do |t|
      t.belongs_to :snitch_report

      t.string   :klass
      t.string   :title
      t.text     :details
      t.text     :backtrace

      t.integer  :occurrence_position

      t.timestamps
    end
  end
end
