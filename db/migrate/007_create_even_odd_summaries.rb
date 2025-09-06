class CreateEvenOddSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :even_odd_summaries do |t|
      t.string :game_type, null: false # 'vietlot45' or 'vietlot55'
      t.string :even_odd_type, null: false # 'even' or 'odd'
      t.integer :number, null: false # The lottery number (1-45 or 1-55)
      t.integer :count, null: false # How many times this number appeared in even/odd date draws
      t.decimal :percentage, precision: 5, scale: 2 # Percentage of appearances

      t.timestamps
    end

    add_index :even_odd_summaries, [:game_type, :even_odd_type]
    add_index :even_odd_summaries, :number
    add_index :even_odd_summaries, :count
  end
end
