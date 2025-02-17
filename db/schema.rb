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

ActiveRecord::Schema[8.0].define(version: 2025_02_16_112645) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "materials", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_materials_on_name", unique: true
  end

  create_table "partner_services", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id", "service_id"], name: "index_partner_services_on_partner_id_and_service_id", unique: true
    t.index ["partner_id"], name: "index_partner_services_on_partner_id"
    t.index ["service_id"], name: "index_partner_services_on_service_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name", null: false
    t.geography "geog", limit: {srid: 4326, type: "st_point", geographic: true}, null: false
    t.float "operating_radius", null: false
    t.float "rating", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geog"], name: "index_partners_on_geog", using: :gist
    t.index ["rating"], name: "index_partners_on_rating"
  end

  create_table "service_materials", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "material_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_service_materials_on_material_id"
    t.index ["service_id", "material_id"], name: "index_service_materials_on_service_id_and_material_id", unique: true
    t.index ["service_id"], name: "index_service_materials_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  add_foreign_key "partner_services", "partners"
  add_foreign_key "partner_services", "services"
  add_foreign_key "service_materials", "materials"
  add_foreign_key "service_materials", "services"
end
