class CreateDayOfMonthSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :day_of_month_summaries do |t|
      t.string :game_type, null: false # 'vietlot45' or 'vietlot55'
      t.integer :day_of_month, null: false # 1-31
      t.integer :number, null: false # The lottery number (1-45 or 1-55)
      t.integer :count, null: false # How many times this number appeared on this day of month
      t.decimal :percentage, precision: 5, scale: 2 # Percentage of appearances

      t.timestamps
    end

    add_index :day_of_month_summaries, [:game_type, :day_of_month]
    add_index :day_of_month_summaries, :number
    add_index :day_of_month_summaries, :count
  end
end
