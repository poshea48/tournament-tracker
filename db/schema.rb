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

ActiveRecord::Schema.define(version: 2018_11_03_012901) do

  create_table "games", force: :cascade do |t|
    t.integer "tournament_id"
    t.integer "court_id"
    t.integer "round"
    t.string "team_ids"
    t.string "winner"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "score"
    t.index ["tournament_id"], name: "index_games_on_tournament_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tournament_id"
    t.integer "player2_id"
    t.string "team_name"
    t.integer "pool_diff", default: 0
    t.string "playoffs"
    t.string "place"
    t.string "pool_record", default: "0-0"
    t.index ["tournament_id"], name: "index_teams_on_tournament_id"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name"
    t.string "date"
    t.boolean "registration_open", default: true
    t.boolean "closed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tournament_type"
    t.boolean "poolplay_started", default: false
    t.boolean "poolplay_finished", default: false
    t.boolean "playoffs_started", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.integer "points", default: 0
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
