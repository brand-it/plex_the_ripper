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

ActiveRecord::Schema.define(version: 2020_09_07_015106) do

  create_table "configs", force: :cascade do |t|
    t.string "type", default: "Config", null: false
    t.text "settings"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "disk_titles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "duration"
    t.integer "title_id", null: false
    t.float "size"
    t.text "message"
    t.integer "disk_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disk_id"], name: "index_disk_titles_on_disk_id"
  end

  create_table "disks", force: :cascade do |t|
    t.string "name"
    t.string "disk_name"
    t.string "workflow_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "episodes", force: :cascade do |t|
    t.string "name"
    t.integer "episode_number"
    t.integer "the_movie_db_id"
    t.string "overview"
    t.string "still_path"
    t.date "air_date"
    t.string "file_path"
    t.string "workflow_state"
    t.integer "season_id"
    t.integer "disk_id"
    t.integer "disk_title_id"
    t.index ["disk_id"], name: "index_episodes_on_disk_id"
    t.index ["disk_title_id"], name: "index_episodes_on_disk_title_id"
    t.index ["season_id"], name: "index_episodes_on_season_id"
  end

  create_table "mkv_progresses", force: :cascade do |t|
    t.string "name"
    t.float "percentage"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.integer "disk_title_id"
    t.string "video_type"
    t.integer "video_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disk_title_id"], name: "index_mkv_progresses_on_disk_title_id"
    t.index ["video_type", "video_id"], name: "index_mkv_progresses_on_video_type_and_video_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.string "original_title"
    t.string "workflow_state"
    t.date "release_date"
    t.string "poster_path"
    t.string "backdrop_path"
    t.integer "the_movie_db_id"
    t.string "overview"
    t.string "file_path"
    t.integer "disk_id"
    t.integer "disk_title_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disk_id"], name: "index_movies_on_disk_id"
    t.index ["disk_title_id"], name: "index_movies_on_disk_title_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.string "overview"
    t.string "poster_path"
    t.integer "the_movie_db_id"
    t.integer "season_number"
    t.date "air_date"
    t.integer "tv_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tv_id"], name: "index_seasons_on_tv_id"
  end

  create_table "tvs", force: :cascade do |t|
    t.string "name"
    t.string "original_name"
    t.string "first_air_date"
    t.string "poster_path"
    t.string "backdrop_path"
    t.integer "the_movie_db_id"
    t.string "episode_run_time"
    t.string "overview"
    t.integer "disk_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disk_id"], name: "index_tvs_on_disk_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "config_type", null: false
    t.integer "config_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["config_type", "config_id"], name: "index_users_on_config_type_and_config_id"
  end

end
