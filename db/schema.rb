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

ActiveRecord::Schema.define(version: 20190823040559) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "guests", force: true do |t|
    t.string   "name",                                    null: false
    t.string   "surname",                                 null: false
    t.string   "gender",                                  null: false
    t.date     "date_of_birth",                           null: false
    t.string   "country_of_birth",                        null: false
    t.string   "nationality",                             null: false
    t.string   "passport_number",                         null: false
    t.boolean  "group_leader",            default: false
    t.boolean  "synced_to_police_portal", default: false
    t.integer  "reservation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guests", ["reservation_id"], name: "index_guests_on_reservation_id", using: :btree

  create_table "properties", force: true do |t|
    t.string   "name",       null: false
    t.string   "location",   null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "properties", ["user_id"], name: "index_properties_on_user_id", using: :btree

  create_table "reservations", force: true do |t|
    t.date     "checkin_date",  null: false
    t.date     "checkout_date", null: false
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservations", ["property_id"], name: "index_reservations_on_property_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                   null: false
    t.string   "police_portal_username"
    t.string   "police_portal_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
