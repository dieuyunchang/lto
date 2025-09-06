class CreateLotteryDraws < ActiveRecord::Migration[5.2]
  def change
    create_table :lottery_draws do |t|
      t.string :game_type, null: false # 'vietlot45' or 'vietlot55'
      t.date :draw_date, null: false
      t.string :date_string, null: false # Original date format like "T4, 27/08/2025"
      t.string :numbers, null: false # "03 11 18 39 40 42"
      t.bigint :prize_amount, null: false
      t.string :prize_string, null: false # "48.376.258.000≈ 48.4 Tỷ"
      t.integer :total, null: false
      t.string :total_even_or_odd, null: false # "odd" or "even"
      t.integer :odd_count, null: false
      t.integer :even_count, null: false
      t.string :template_id, null: false # "T66"
      t.integer :template_appear_comback_from_prev_count, null: false
      t.integer :template_continuos_count, null: false
      t.integer :template_appear_count, null: false

      t.timestamps
    end

    add_index :lottery_draws, [:game_type, :draw_date], unique: true
    add_index :lottery_draws, :template_id
    add_index :lottery_draws, :draw_date
  end
end
