class CreatePredictions < ActiveRecord::Migration[6.1]
  def change
    create_table :predictions do |t|
      t.string :game_type, null: false # 'vietlot45' or 'vietlot55'
      t.integer :number, null: false # The predicted number
      t.decimal :score, precision: 10, scale: 6, null: false
      t.string :trend, null: false # "up", "down", "stable"
      t.decimal :strength, precision: 10, scale: 6, null: false
      t.string :confidence, null: false # "high", "medium", "low"
      t.decimal :forecast, precision: 10, scale: 6, null: false
      t.datetime :prediction_date, null: false

      t.timestamps
    end

    add_index :predictions, [:game_type, :prediction_date]
    add_index :predictions, :number
    add_index :predictions, :confidence
  end
end
