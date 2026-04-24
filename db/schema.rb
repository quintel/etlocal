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

ActiveRecord::Schema[8.1].define(version: 2026_04_23_120959) do
  create_table "commits", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "dataset_id"
    t.text "message"
    t.integer "source_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["dataset_id"], name: "index_commits_on_dataset_id"
    t.index ["source_id"], name: "index_commits_on_source_id"
    t.index ["user_id"], name: "index_commits_on_user_id"
  end

  create_table "dataset_edits", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "boolean_value"
    t.integer "commit_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "key"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.float "value", limit: 53
    t.index ["commit_id"], name: "index_dataset_edits_on_commit_id"
  end

  create_table "datasets", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "data_source", default: "db", null: false
    t.string "geo_id", default: "", null: false
    t.boolean "has_agriculture", default: false
    t.boolean "has_industry", default: false
    t.string "name", default: "", null: false
    t.string "parent"
    t.boolean "public", default: true
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_datasets_on_user_id"
  end

  create_table "groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "key"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "sources", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "source_file_content_type"
    t.string "source_file_file_name"
    t.integer "source_file_file_size"
    t.datetime "source_file_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "email", limit: 191, default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "group_id"
    t.string "name"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token", limit: 191
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
