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

ActiveRecord::Schema.define(version: 20141107081255) do

  create_table "colleges", force: true do |t|
    t.string   "name"
    t.string   "coladd"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "colname"
  end

  create_table "courses", force: true do |t|
    t.string   "cname"
    t.string   "cdesc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses_students", force: true do |t|
    t.integer  "student_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_uploads", force: true do |t|
    t.string   "fname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studentids", force: true do |t|
    t.string   "name"
    t.string   "descp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "idcards"
  end

  create_table "students", force: true do |t|
    t.string   "name"
    t.integer  "phone"
    t.integer  "age"
    t.text     "address"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.string   "image_filename"
    t.integer  "college_id"
    t.integer  "studentid_id"
    t.string   "status"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "provider",               default: "", null: false
    t.string   "uid",                    default: "", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
