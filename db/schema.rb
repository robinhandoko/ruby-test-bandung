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

ActiveRecord::Schema.define(version: 20161001040144) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "backup_files", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "parent_id"
    t.string   "backup_type"
    t.integer  "gid"
    t.integer  "uid"
    t.float    "file_size"
    t.integer  "access_number"
    t.datetime "last_modified_time"
    t.string   "md5"
    t.string   "file_name"
    t.string   "folder_name"
    t.boolean  "is_current_version", default: true
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "backup_files", ["profile_id"], name: "index_backup_files_on_profile_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.float    "storage",      default: 0.0
    t.datetime "last_backup"
    t.text     "include_path"
    t.text     "exclude_path"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                     default: "", null: false
    t.string   "encrypted_password",        default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "encrypted_otp_secret"
    t.string   "encrypted_otp_secret_iv"
    t.string   "encrypted_otp_secret_salt"
    t.integer  "consumed_timestep"
    t.boolean  "otp_required_for_login"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
