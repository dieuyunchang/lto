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

ActiveRecord::Schema[7.1].define(version: 7) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "day_of_month_summaries", force: :cascade do |t|
    t.string "game_type", null: false
    t.integer "day_of_month", null: false
    t.integer "number", null: false
    t.integer "count", null: false
    t.decimal "percentage", precision: 5, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["count"], name: "index_day_of_month_summaries_on_count"
    t.index ["game_type", "day_of_month"], name: "index_day_of_month_summaries_on_game_type_and_day_of_month"
    t.index ["number"], name: "index_day_of_month_summaries_on_number"
  end

  create_table "day_of_week_summaries", force: :cascade do |t|
    t.string "game_type", null: false
    t.string "day_of_week", null: false
    t.integer "number", null: false
    t.integer "count", null: false
    t.decimal "percentage", precision: 5, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["count"], name: "index_day_of_week_summaries_on_count"
    t.index ["game_type", "day_of_week"], name: "index_day_of_week_summaries_on_game_type_and_day_of_week"
    t.index ["number"], name: "index_day_of_week_summaries_on_number"
  end

  create_table "even_odd_summaries", force: :cascade do |t|
    t.string "game_type", null: false
    t.string "even_odd_type", null: false
    t.integer "number", null: false
    t.integer "count", null: false
    t.decimal "percentage", precision: 5, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["count"], name: "index_even_odd_summaries_on_count"
    t.index ["game_type", "even_odd_type"], name: "index_even_odd_summaries_on_game_type_and_even_odd_type"
    t.index ["number"], name: "index_even_odd_summaries_on_number"
  end

  create_table "lottery_draws", force: :cascade do |t|
    t.string "game_type", null: false
    t.date "draw_date", null: false
    t.string "date_string", null: false
    t.string "numbers", null: false
    t.bigint "prize_amount", null: false
    t.string "prize_string", null: false
    t.integer "total", null: false
    t.string "total_even_or_odd", null: false
    t.integer "odd_count", null: false
    t.integer "even_count", null: false
    t.string "template_id", null: false
    t.integer "template_appear_comback_from_prev_count", null: false
    t.integer "template_continuos_count", null: false
    t.integer "template_appear_count", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["draw_date"], name: "index_lottery_draws_on_draw_date"
    t.index ["game_type", "draw_date"], name: "index_lottery_draws_on_game_type_and_draw_date", unique: true
    t.index ["template_id"], name: "index_lottery_draws_on_template_id"
  end

  create_table "month_summaries", force: :cascade do |t|
    t.string "game_type", null: false
    t.integer "month", null: false
    t.integer "number", null: false
    t.integer "count", null: false
    t.decimal "percentage", precision: 5, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["count"], name: "index_month_summaries_on_count"
    t.index ["game_type", "month"], name: "index_month_summaries_on_game_type_and_month"
    t.index ["number"], name: "index_month_summaries_on_number"
  end

  create_table "predictions", force: :cascade do |t|
    t.string "game_type", null: false
    t.integer "number", null: false
    t.decimal "score", precision: 10, scale: 6, null: false
    t.string "trend", null: false
    t.decimal "strength", precision: 10, scale: 6, null: false
    t.string "confidence", null: false
    t.decimal "forecast", precision: 10, scale: 6, null: false
    t.datetime "prediction_date", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confidence"], name: "index_predictions_on_confidence"
    t.index ["game_type", "prediction_date"], name: "index_predictions_on_game_type_and_prediction_date"
    t.index ["number"], name: "index_predictions_on_number"
  end

  create_table "template_predictions", force: :cascade do |t|
    t.string "game_type", null: false
    t.string "template_id", null: false
    t.integer "total_appearances", null: false
    t.integer "days_since_last", null: false
    t.integer "current_continuous_count", null: false
    t.decimal "average_comeback_interval", precision: 10, scale: 2, null: false
    t.integer "max_continuous_count", null: false
    t.integer "comeback_pattern_score", null: false
    t.integer "continuous_pattern_score", null: false
    t.integer "frequency_pattern_score", null: false
    t.integer "recent_trend_score", null: false
    t.integer "overall_probability", null: false
    t.integer "confidence_level", null: false
    t.string "last_appearance", null: false
    t.datetime "prediction_date", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confidence_level"], name: "index_template_predictions_on_confidence_level"
    t.index ["game_type", "prediction_date"], name: "index_template_predictions_on_game_type_and_prediction_date"
    t.index ["overall_probability"], name: "index_template_predictions_on_overall_probability"
    t.index ["template_id"], name: "index_template_predictions_on_template_id"
  end

end
