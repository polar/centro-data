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

ActiveRecord::Schema.define(version: 20130919190512) do

  create_table "apis", force: true do |t|
    t.integer  "major_version"
    t.integer  "minor_version"
    t.string   "mode"
    t.string   "name"
    t.string   "slug"
    t.string   "auth"
    t.string   "login"
    t.string   "register"
    t.string   "logout"
    t.integer  "postloc_time_rate"
    t.integer  "postloc_dist_rate"
    t.integer  "curloc_time_rate"
    t.integer  "marker_time_rate"
    t.float    "lon"
    t.float    "lat"
    t.string   "timezone"
    t.datetime "time"
    t.string   "time_offset"
    t.string   "datefmt"
    t.string   "get_route_journey_ids"
    t.string   "get_route_definition"
    t.string   "get_journey_location"
    t.string   "get_multiple_journey_locations"
    t.string   "post_journey_location"
    t.string   "get_messages"
    t.string   "get_markers"
    t.string   "post_feedback"
    t.string   "a_update"
    t.integer  "update_rate"
    t.integer  "active_start_display_threshold"
    t.integer  "active_end_wait_threshold"
    t.float    "off_route_distance_threshold"
    t.float    "off_route_time_threshold"
    t.integer  "off_route_count_threshold"
    t.string   "get_route_journey_ids1"
    t.integer  "sync_rate"
    t.integer  "banner_refresh_rate"
    t.integer  "banner_max_image_size"
    t.string   "help_url"
    t.string   "box"
    t.string   "marker_click_thru"
    t.string   "message_click_thru"
    t.string   "banner_click_thru"
    t.string   "banner_image"
    t.integer  "master_id"
  end

  create_table "centro_buses", force: true do |t|
    t.string   "centroid"
    t.string   "rt"
    t.string   "rtdd"
    t.string   "d"
    t.string   "dd"
    t.string   "dn"
    t.float    "lat"
    t.float    "lon"
    t.string   "pid"
    t.string   "pd"
    t.string   "run"
    t.string   "fs"
    t.string   "op"
    t.integer  "dip"
    t.integer  "bid"
    t.string   "wid1"
    t.string   "wid2"
    t.string   "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "journeys", force: true do |t|
    t.string  "persistentid"
    t.string  "route_type"
    t.float   "dir"
    t.float   "sort"
    t.string  "route_code"
    t.integer "version"
    t.string  "name"
    t.boolean "timeless"
    t.integer "start_offset"
    t.integer "duration"
    t.string  "vid"
    t.integer "location_refresh_rate"
    t.float   "nw_lon"
    t.float   "nw_lat"
    t.float   "se_lon"
    t.float   "se_lat"
    t.string  "patternid"
    t.integer "api_id"
    t.integer "pattern_id"
    t.integer "master_id"
  end

  create_table "masters", force: true do |t|
    t.string  "name"
    t.string  "slug"
    t.float   "lon"
    t.float   "lat"
    t.string  "bounds"
    t.string  "api_url"
    t.string  "title"
    t.text    "description"
    t.integer "api_id"
  end

  create_table "messages", force: true do |t|
    t.string   "mid"
    t.string   "go_url"
    t.integer  "remind_period"
    t.boolean  "remindable"
    t.datetime "expiry_time"
    t.integer  "version"
    t.string   "title"
    t.text     "content"
    t.integer  "api_id"
    t.integer  "master_id"
  end

  create_table "patterns", force: true do |t|
    t.string  "persistentid"
    t.string  "route_type"
    t.integer "version"
    t.float   "distance"
    t.string  "coords"
    t.integer "api_id"
    t.integer "master_id"
  end

  create_table "routes", force: true do |t|
    t.string  "persistentid"
    t.string  "route_type"
    t.string  "name"
    t.string  "route_code"
    t.float   "sort"
    t.integer "version"
    t.float   "nw_lon"
    t.float   "nw_lat"
    t.float   "se_lon"
    t.float   "se_lat"
    t.string  "patternids"
    t.integer "api_id"
    t.integer "master_id"
  end

  create_table "user_logins", force: true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "roles"
    t.string  "role_intent"
    t.string  "auth_token"
    t.string  "status"
    t.integer "api_id"
    t.integer "master_id"
  end

end
