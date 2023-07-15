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

ActiveRecord::Schema[7.0].define(version: 2023_07_14_231625) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "social_networks", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "base_link", null: false
  end

  create_table "user_socials", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "social_network_id"
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["social_network_id"], name: "index_user_socials_on_social_network_id"
    t.index ["user_id"], name: "index_user_socials_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "title", null: false
    t.integer "followers", null: false
    t.integer "views_on_video", null: false
    t.string "bio", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subtitle", null: false
    t.string "tiktok_link", null: false
  end

  add_foreign_key "user_socials", "social_networks"
  add_foreign_key "user_socials", "users"
end
