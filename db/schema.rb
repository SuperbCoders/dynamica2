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

ActiveRecord::Schema.define(version: 20160302075354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: true do |t|
    t.text     "fields",                      null: false
    t.integer  "project_id",                  null: false
    t.integer  "remote_id",         limit: 8, null: false
    t.datetime "remote_updated_at",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["project_id"], name: "index_customers_on_project_id", using: :btree

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

  create_table "integrations", force: true do |t|
    t.integer  "project_id",   null: false
    t.string   "code"
    t.string   "access_token"
    t.string   "type",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "integrations", ["project_id"], name: "index_integrations_on_project_id", using: :btree

  create_table "items", force: true do |t|
    t.integer  "project_id"
    t.string   "sku"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "values_count", default: 0
    t.string   "attachment"
  end

  add_index "items", ["project_id", "sku"], name: "index_items_on_project_id_and_sku", unique: true, using: :btree
  add_index "items", ["project_id"], name: "index_items_on_project_id", using: :btree

  create_table "line_items", force: true do |t|
    t.text     "fields",                      null: false
    t.integer  "project_id",                  null: false
    t.integer  "remote_id",         limit: 8, null: false
    t.datetime "remote_updated_at",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["project_id"], name: "index_line_items_on_project_id", using: :btree

  create_table "logs", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "key"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logs", ["project_id"], name: "index_logs_on_project_id", using: :btree
  add_index "logs", ["user_id"], name: "index_logs_on_user_id", using: :btree

  create_table "orders", force: true do |t|
    t.text     "fields",                      null: false
    t.integer  "project_id",                  null: false
    t.integer  "remote_id",         limit: 8, null: false
    t.datetime "remote_updated_at",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["project_id"], name: "index_orders_on_project_id", using: :btree

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
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "predicted",        default: false
    t.datetime "from"
    t.datetime "to"
  end

  add_index "predicted_values", ["forecast_line_id"], name: "index_predicted_values_on_forecast_line_id", using: :btree

  create_table "product_characteristics", force: true do |t|
    t.integer  "product_id",                                           null: false
    t.decimal  "price",         precision: 10, scale: 2, default: 0.0, null: false
    t.integer  "sold_quantity",                          default: 0,   null: false
    t.decimal  "gross_revenue", precision: 10, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date",                                                 null: false
  end

  add_index "product_characteristics", ["product_id"], name: "index_product_characteristics_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.integer  "remote_id",          limit: 8,              null: false
    t.integer  "project_id",                                null: false
    t.string   "title",                        default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_quantity",           default: 0,  null: false
    t.text     "fields"
    t.datetime "remote_updated_at"
  end

  add_index "products", ["project_id"], name: "index_products_on_project_id", using: :btree
  add_index "products", ["remote_id", "project_id"], name: "index_products_on_remote_id_and_project_id", unique: true, using: :btree
  add_index "products", ["remote_id"], name: "index_products_on_remote_id", using: :btree

  create_table "project_characteristics", force: true do |t|
    t.integer  "orders_number",                                                           default: 0,     null: false
    t.integer  "products_number",                                                         default: 0,     null: false
    t.integer  "project_id",                                                                              null: false
    t.decimal  "total_gross_revenues",                           precision: 10, scale: 2, default: 0.0,   null: false
    t.decimal  "total_prices",                                   precision: 10, scale: 2
    t.string   "currency",                                                                default: "USD", null: false
    t.integer  "customers_number",                                                        default: 0,     null: false
    t.integer  "new_customers_number",                                                    default: 0,     null: false
    t.integer  "repeat_customers_number",                                                 default: 0,     null: false
    t.float    "ratio_of_new_customers_to_repeat_customers",                              default: 0.0,   null: false
    t.float    "average_order_value",                                                     default: 0.0,   null: false
    t.float    "average_order_size",                                                      default: 0.0,   null: false
    t.integer  "abandoned_shopping_cart_sessions_number"
    t.float    "average_revenue_per_customer",                                            default: 0.0,   null: false
    t.float    "sales_per_visitor",                                                       default: 0.0,   null: false
    t.float    "average_customer_lifetime_value",                                         default: 0.0,   null: false
    t.float    "shipping_cost_as_a_percentage_of_total_revenue",                          default: 0.0,   null: false
    t.integer  "unique_users_number",                                                     default: 0,     null: false
    t.integer  "visits",                                                                  default: 0,     null: false
    t.float    "time_on_site",                                                            default: 0.0,   null: false
    t.integer  "products_in_stock_number",                                                default: 0,     null: false
    t.integer  "items_in_stock_number",                                                   default: 0,     null: false
    t.float    "percentage_of_inventory_sold",                                            default: 0.0,   null: false
    t.float    "percentage_of_stock_sold",                                                default: 0.0,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date",                                                                                    null: false
  end

  add_index "project_characteristics", ["project_id"], name: "index_project_characteristics_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "api_used",    default: false
    t.boolean  "demo",        default: false
    t.string   "guest_token"
  end

  add_index "projects", ["slug"], name: "index_projects_on_slug", unique: true, using: :btree
  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "third_party_shopify_integrations", force: true do |t|
    t.integer  "project_id"
    t.string   "token"
    t.string   "shop_name"
    t.datetime "last_import_at"
    t.integer  "fails_count",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "third_party_shopify_integrations", ["project_id"], name: "index_third_party_shopify_integrations_on_project_id", using: :btree

  create_table "third_party_shopify_orders", force: true do |t|
    t.integer  "integration_id"
    t.string   "shopify_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "third_party_shopify_orders", ["integration_id"], name: "index_third_party_shopify_orders_on_integration_id", using: :btree

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
    t.string   "name"
    t.string   "avatar"
    t.string   "role"
  end

  add_index "users", ["api_token"], name: "index_users_on_api_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

  create_table "values", force: true do |t|
    t.integer  "item_id"
    t.float    "value"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "values", ["item_id"], name: "index_values_on_item_id", using: :btree

end
