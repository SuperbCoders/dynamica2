# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141224133603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: true do |t|
    t.integer  "project_id"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["project_id"], name: "index_attachments_on_project_id", using: :btree

  create_table "forecast_lines", force: true do |t|
    t.integer  "forecast_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "summary",     default: false
  end

  add_index "forecast_lines", ["forecast_id", "item_id"], name: "index_forecast_lines_on_forecast_id_and_item_id", unique: true, using: :btree
  add_index "forecast_lines", ["forecast_id"], name: "index_forecast_lines_on_forecast_id", using: :btree
  add_index "forecast_lines", ["item_id"], name: "index_forecast_lines_on_item_id", using: :btree

  create_table "forecasts", force: true do |t|
    t.boolean  "scheduled",      default: false
    t.string   "period"
    t.integer  "depth"
    t.string   "group_method"
    t.string   "workflow_state"
    t.datetime "planned_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "from"
    t.datetime "to"
    t.integer  "project_id"
  end

  add_index "forecasts", ["project_id"], name: "index_forecasts_on_project_id", using: :btree

  create_table "items", force: true do |t|
    t.integer  "project_id"
    t.string   "sku"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["project_id", "sku"], name: "index_items_on_project_id_and_sku", unique: true, using: :btree
  add_index "items", ["project_id"], name: "index_items_on_project_id", using: :btree

  create_table "pending_permissions", force: true do |t|
    t.string   "email"
    t.integer  "project_id"
    t.boolean  "manage"
    t.boolean  "forecasting"
    t.boolean  "read"
    t.boolean  "api"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pending_permissions", ["project_id", "email"], name: "index_pending_permissions_on_project_id_and_email", unique: true, using: :btree
  add_index "pending_permissions", ["project_id"], name: "index_pending_permissions_on_project_id", using: :btree
  add_index "pending_permissions", ["token"], name: "index_pending_permissions_on_token", unique: true, using: :btree

  create_table "permissions", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manage",      default: false
    t.boolean  "forecasting", default: false
    t.boolean  "read",        default: false
    t.boolean  "api",         default: false
  end

  add_index "permissions", ["project_id"], name: "index_permissions_on_project_id", using: :btree
  add_index "permissions", ["user_id", "project_id"], name: "index_permissions_on_user_id_and_project_id", unique: true, using: :btree
  add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

  create_table "predicted_values", force: true do |t|
    t.integer  "forecast_line_id"
    t.string   "timestamp"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "predicted",        default: false
    t.datetime "from"
    t.datetime "to"
  end

  add_index "predicted_values", ["forecast_line_id", "timestamp"], name: "index_predicted_values_on_forecast_line_id_and_timestamp", unique: true, using: :btree
  add_index "predicted_values", ["forecast_line_id"], name: "index_predicted_values_on_forecast_line_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "projects", ["slug"], name: "index_projects_on_slug", unique: true, using: :btree
  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["api_token"], name: "index_users_on_api_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "values", force: true do |t|
    t.integer  "item_id"
    t.float    "value"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "values", ["item_id"], name: "index_values_on_item_id", using: :btree

end
