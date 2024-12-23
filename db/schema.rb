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

ActiveRecord::Schema[7.2].define(version: 2024_12_10_214438) do
  create_table "configs", force: :cascade do |t|
    t.string "type", default: "Config", null: false
    t.text "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disk_titles", force: :cascade do |t|
    t.string "name"
    t.integer "duration"
    t.integer "title_id", null: false
    t.integer "size", default: 0, null: false
    t.bigint "mkv_progress_id"
    t.bigint "disk_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "video_id"
    t.integer "episode_id"
    t.datetime "ripped_at"
    t.integer "video_blob_id"
    t.integer "angle"
    t.string "filename", null: false
    t.string "description"
    t.integer "episode_last_id"
    t.string "segment_map"
    t.index ["disk_id"], name: "index_disk_titles_on_disk_id"
    t.index ["episode_id"], name: "index_disk_titles_on_episode_id"
    t.index ["episode_last_id"], name: "index_disk_titles_on_episode_last_id"
    t.index ["mkv_progress_id"], name: "index_disk_titles_on_mkv_progress_id"
    t.index ["video_blob_id"], name: "index_disk_titles_on_video_blob_id"
    t.index ["video_id"], name: "index_disk_titles_on_video"
  end

  create_table "disks", force: :cascade do |t|
    t.string "name"
    t.string "disk_name"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ejected", default: true, null: false
    t.integer "video_id"
    t.integer "episode_id"
    t.boolean "loading", default: false, null: false
    t.index ["episode_id"], name: "index_disks_on_episode_id"
    t.index ["video_id"], name: "index_disks_on_video"
  end

  create_table "episodes", force: :cascade do |t|
    t.string "name"
    t.string "overview"
    t.string "still_path"
    t.string "file_path"
    t.string "workflow_state"
    t.integer "episode_number"
    t.integer "the_movie_db_id"
    t.date "air_date"
    t.bigint "season_id"
    t.integer "runtime"
    t.index ["season_id"], name: "index_episodes_on_season_id"
    t.index ["the_movie_db_id"], name: "index_episodes_on_the_movie_db_id", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "ended_at"
    t.datetime "started_at"
    t.string "error_class"
    t.string "error_message"
    t.string "name", null: false
    t.string "status", default: "enqueued", null: false
    t.text "arguments"
    t.text "backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "metadata", default: "{}", null: false
  end

  create_table "progresses", force: :cascade do |t|
    t.string "key"
    t.float "percentage"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.text "message"
    t.string "progressable_type"
    t.integer "progressable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attempts", default: 0, null: false
    t.integer "descriptive", default: 0, null: false
    t.index ["progressable_type", "progressable_id"], name: "index_progresses_on_progressable_type_and_progressable_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.string "overview"
    t.string "poster_path"
    t.integer "the_movie_db_id"
    t.integer "season_number"
    t.date "air_date"
    t.bigint "tv_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tv_id"], name: "index_seasons_on_tv_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "config_type"
    t.bigint "config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", limit: 255, default: "Pacific Time (US & Canada)", null: false
    t.index ["config_type", "config_id"], name: "index_users_on_config_type_and_config_id"
  end

  create_table "video_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type", null: false
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.boolean "optimized", default: false, null: false
    t.text "checksum"
    t.integer "video_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "episode_id"
    t.integer "extra_type", default: 0
    t.integer "extra_type_number"
    t.datetime "uploaded_on"
    t.boolean "uploadable", default: false, null: false
    t.string "edition"
    t.integer "part"
    t.integer "episode_last_id"
    t.index ["episode_last_id"], name: "index_video_blobs_on_episode_last_id"
    t.index ["extra_type_number", "video_id", "extra_type"], name: "idx_on_extra_type_number_video_id_extra_type_1978193db6", unique: true
    t.index ["key"], name: "index_video_blobs_on_key", unique: true
    t.index ["key"], name: "index_video_blobs_on_key_and_service_name", unique: true
    t.index ["video_id"], name: "index_video_blobs_on_video"
  end

  create_table "videos", force: :cascade do |t|
    t.string "title"
    t.string "original_title"
    t.string "poster_path"
    t.string "backdrop_path"
    t.string "overview"
    t.string "type"
    t.string "episode_distribution_runtime"
    t.integer "the_movie_db_id"
    t.integer "movie_runtime"
    t.float "popularity"
    t.date "release_date"
    t.date "episode_first_air_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rating", default: 0, null: false
    t.boolean "auto_start", default: false, null: false
    t.index ["type", "the_movie_db_id"], name: "index_videos_on_type_and_the_movie_db_id", unique: true
  end
end
