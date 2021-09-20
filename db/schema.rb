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

ActiveRecord::Schema.define(version: 2021_09_19_185445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.string "name"
    t.string "departure_city_name"
    t.string "destination_city_name"
    t.integer "price"
    t.integer "bus_category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "departure_city_url_name"
    t.integer "departure_city_id"
    t.string "destination_city_url_name"
    t.integer "destination_city_id"
  end

  create_table "bus_travels", force: :cascade do |t|
    t.string "date"
    t.string "time"
    t.integer "bus_category"
    t.float "price"
    t.string "company"
    t.bigint "alert_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_id"], name: "index_bus_travels_on_alert_id"
    t.index ["date"], name: "index_bus_travels_on_date"
  end

  create_table "price_histories", force: :cascade do |t|
    t.bigint "alert_id"
    t.float "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alert_id"], name: "index_price_histories_on_alert_id"
  end

  add_foreign_key "bus_travels", "alerts"
  add_foreign_key "price_histories", "alerts"
end
