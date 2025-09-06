class CreateTemplatePredictions < ActiveRecord::Migration[5.2]
  def change
    create_table :template_predictions do |t|
      t.string :game_type, null: false # 'vietlot45' or 'vietlot55'
      t.string :template_id, null: false # "T21"
      t.integer :total_appearances, null: false
      t.integer :days_since_last, null: false
      t.integer :current_continuous_count, null: false
      t.decimal :average_comeback_interval, precision: 10, scale: 2, null: false
      t.integer :max_continuous_count, null: false
      t.integer :comeback_pattern_score, null: false
      t.integer :continuous_pattern_score, null: false
      t.integer :frequency_pattern_score, null: false
      t.integer :recent_trend_score, null: false
      t.integer :overall_probability, null: false
      t.integer :confidence_level, null: false
      t.string :last_appearance, null: false # "CN, 31/12/2017"
      t.datetime :prediction_date, null: false

      t.timestamps
    end

    add_index :template_predictions, [:game_type, :prediction_date]
    add_index :template_predictions, :template_id
    add_index :template_predictions, :overall_probability
    add_index :template_predictions, :confidence_level
  end
end
