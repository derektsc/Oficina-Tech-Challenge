# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_08_19_120007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "catalog_services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 12, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "document", null: false
    t.string "document_type", null: false
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document"], name: "index_customers_on_document", unique: true
  end

  create_table "parts", force: :cascade do |t|
    t.string "name", null: false
    t.string "sku", null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.integer "stock_quantity", default: 0, null: false
    t.integer "minimum_stock", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_parts_on_sku", unique: true
  end

  create_table "service_order_items", force: :cascade do |t|
    t.bigint "service_order_id", null: false
    t.string "item_type", null: false
    t.bigint "catalog_service_id"
    t.bigint "part_id"
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.decimal "total_price", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_service_id"], name: "index_service_order_items_on_catalog_service_id"
    t.index ["part_id"], name: "index_service_order_items_on_part_id"
    t.index ["service_order_id"], name: "index_service_order_items_on_service_order_id"
  end

  create_table "service_orders", force: :cascade do |t|
    t.string "number", null: false
    t.string "public_token", null: false
    t.bigint "customer_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "status", default: "received", null: false
    t.decimal "budget_total", precision: 12, scale: 2, default: "0.0", null: false
    t.text "notes"
    t.datetime "received_at"
    t.datetime "diagnosis_started_at"
    t.datetime "budget_sent_at"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "execution_started_at"
    t.datetime "finished_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_service_orders_on_customer_id"
    t.index ["number"], name: "index_service_orders_on_number", unique: true
    t.index ["public_token"], name: "index_service_orders_on_public_token", unique: true
    t.index ["status"], name: "index_service_orders_on_status"
    t.index ["vehicle_id"], name: "index_service_orders_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "admin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "plate", null: false
    t.string "brand", null: false
    t.string "model", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_vehicles_on_customer_id"
    t.index ["plate"], name: "index_vehicles_on_plate", unique: true
  end

  add_foreign_key "service_order_items", "catalog_services"
  add_foreign_key "service_order_items", "parts"
  add_foreign_key "service_order_items", "service_orders"
  add_foreign_key "service_orders", "customers"
  add_foreign_key "service_orders", "vehicles"
  add_foreign_key "vehicles", "customers"
end
