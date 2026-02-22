class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :student, null: false, foreign_key: true
      t.references :text, null: false, foreign_key: true
      t.integer :duration_seconds
      t.integer :score_wpm

      t.timestamps
    end
  end
end
