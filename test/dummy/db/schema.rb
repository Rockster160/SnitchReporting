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

ActiveRecord::Schema.define(version: 2020_01_03_014637) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "snitch_reporting_snitch_comments", force: :cascade do |t|
    t.bigint "report_id"
    t.bigint "author_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_snitch_reporting_snitch_comments_on_author_id"
    t.index ["report_id"], name: "index_snitch_reporting_snitch_comments_on_report_id"
  end

  create_table "snitch_reporting_snitch_histories", force: :cascade do |t|
    t.bigint "report_id"
    t.bigint "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_snitch_reporting_snitch_histories_on_report_id"
    t.index ["user_id"], name: "index_snitch_reporting_snitch_histories_on_user_id"
  end

  create_table "snitch_reporting_snitch_occurrences", force: :cascade do |t|
    t.bigint "report_id"
    t.string "http_method"
    t.string "url"
    t.text "user_agent"
    t.text "backtrace"
    t.text "context"
    t.text "params"
    t.text "headers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_snitch_reporting_snitch_occurrences_on_report_id"
  end

  create_table "snitch_reporting_snitch_reports", force: :cascade do |t|
    t.text "error"
    t.text "message"
    t.integer "log_level"
    t.string "klass"
    t.string "action"
    t.text "tags"
    t.datetime "first_occurrence_at"
    t.datetime "last_occurrence_at"
    t.bigint "occurrence_count"
    t.datetime "resolved_at"
    t.bigint "resolved_by_id"
    t.datetime "ignored_at"
    t.bigint "ignored_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ignored_by_id"], name: "index_snitch_reporting_snitch_reports_on_ignored_by_id"
    t.index ["resolved_by_id"], name: "index_snitch_reporting_snitch_reports_on_resolved_by_id"
  end

  create_table "snitch_reporting_snitch_trackers", force: :cascade do |t|
    t.bigint "report_id"
    t.date "date"
    t.bigint "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_snitch_reporting_snitch_trackers_on_report_id"
  end

end
