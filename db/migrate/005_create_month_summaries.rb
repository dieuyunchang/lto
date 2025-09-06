class CreateMonthSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :month_summaries do |t|
      t.string :game_type, null: false # 'vietlot45' or 'vietlot55'
      t.integer :month, null: false # 1-12
      t.integer :number, null: false # The lottery number (1-45 or 1-55)
      t.integer :count, null: false # How many times this number appeared in this month
      t.decimal :percentage, precision: 5, scale: 2 # Percentage of appearances

      t.timestamps
    end

    add_index :month_summaries, [:game_type, :month]
    add_index :month_summaries, :number
    add_index :month_summaries, :count
  end
end
