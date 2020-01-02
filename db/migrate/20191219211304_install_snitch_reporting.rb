class InstallSnitchReporting < ActiveRecord::Migration[5.2]
  def change
    create_table :snitch_reports do |t|
      t.text :error
      t.text :message
      t.integer :log_level
      t.string :klass
      t.string :action
      t.text :tags

      t.datetime :first_occurrence_at
      t.datetime :last_occurrence_at
      t.bigint :occurrence_count

      t.datetime :resolved_at
      t.belongs_to :resolved_by
      t.datetime :ignored_at
      t.belongs_to :ignored_by

      t.timestamps
    end

    create_table :snitch_occurrences do |t|
      t.belongs_to :snitch_report
      t.string :http_method
      t.string :url
      t.text :user_agent
      t.text :backtrace
      t.text :context
      t.text :params
      t.text :headers

      t.timestamps
    end

    create_table :snitch_comments do |t|
      t.belongs_to :snitch_report
      t.belongs_to :author
      t.text :body

      t.timestamps
    end

    create_table :snitch_histories do |t|
      t.belongs_to :snitch_report
      t.belongs_to :user
      t.text :text

      t.timestamps
    end

    create_table :snitch_trackers do |t|
      t.belongs_to :snitch_report
      t.date :date
      t.bigint :count

      t.timestamps
    end
  end
end
