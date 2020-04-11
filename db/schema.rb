# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_12_022732) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invalid_uploads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "uploaded_at", null: false
    t.text "data", null: false
    t.index ["user_id"], name: "index_invalid_uploads_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "label", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "records", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.datetime "uploaded_at", null: false
    t.jsonb "data", null: false
    t.string "region_designation", null: false, array: true
    t.index ["project_id"], name: "index_records_on_project_id"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "project_id"
    t.string "login", null: false
    t.string "name", null: false
    t.string "language"
    t.string "password"
    t.string "tokens", default: [], array: true
    t.boolean "enabled", default: true
    t.jsonb "admission"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_authn"
    t.bigint "created_by"
    t.index ["project_id", "login"], name: "index_users_on_project_id_and_login", unique: true
    t.index ["project_id"], name: "index_users_on_project_id"
  end

  add_foreign_key "invalid_uploads", "users"
  add_foreign_key "records", "projects"
  add_foreign_key "records", "users"
  add_foreign_key "users", "projects"
end
