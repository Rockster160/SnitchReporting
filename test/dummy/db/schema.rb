# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_10_224002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "snitch_reporting_snitch_occurrences", force: :cascade do |t|
    t.bigint "snitch_report_id"
    t.string "klass"
    t.string "title"
    t.text "details"
    t.text "backtrace"
    t.integer "occurrence_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["snitch_report_id"], name: "index_snitch_reporting_snitch_occurrences_on_snitch_report_id"
  end

  create_table "snitch_reporting_snitch_reports", force: :cascade do |t|
    t.datetime "first_occurrence_at"
    t.datetime "last_occurrence_at"
    t.integer "occurrences_count"
    t.string "title"
    t.string "slug"
    t.string "log_level"
    t.integer "severity"
    t.text "source"
    t.text "custom_details"
    t.datetime "resolved_at"
    t.datetime "ignored_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
