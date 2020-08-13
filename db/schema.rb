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

ActiveRecord::Schema.define(version: 2020_08_13_044833) do

  create_table "configs", force: :cascade do |t|
    t.string "type", default: "Config", null: false
    t.text "settings"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "disk_titles", force: :cascade do |t|
    t.string "name"
    t.integer "duration"
    t.integer "title_id"
    t.float "size"
    t.integer "disk_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disk_id"], name: "index_disk_titles_on_disk_id"
  end

  create_table "disks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "episodes", force: :cascade do |t|
    t.string "name"
    t.integer "episode_number"
    t.integer "the_movie_db_id"
    t.string "overview"
    t.date "air_date"
    t.string "file_path"
    t.string "workflow_state"
    t.integer "season_id"
    t.integer "disk_id"
    t.index ["disk_id"], name: "index_episodes_on_disk_id"
    t.index ["season_id"], name: "index_episodes_on_season_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.string "original_title"
    t.string "workflow_state"
    t.date "release_date"
    t.string "poster_url"
    t.string "backdrop_url"
    t.integer "the_movie_db_id"
    t.string "overview"
    t.string "file_path"
    t.integer "disk_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disk_id"], name: "index_movies_on_disk_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.string "overview"
    t.string "poster_url"
    t.integer "the_movie_db_id"
    t.integer "seasons_number"
    t.date "air_date"
    t.integer "tv_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tv_id"], name: "index_seasons_on_tv_id"
  end

  create_table "tvs", force: :cascade do |t|
    t.string "name"
    t.string "original_name"
    t.string "year"
    t.string "poster_url"
    t.string "backdrop_url"
    t.integer "the_movie_db_id"
    t.integer "episode_run_time"
    t.string "overview"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
