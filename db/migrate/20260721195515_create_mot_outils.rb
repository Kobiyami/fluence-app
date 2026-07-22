class CreateMotOutils < ActiveRecord::Migration[8.1]
  def change
    create_table :mot_outils do |t|
      t.string :text, null: false

      t.timestamps
    end

    add_index :mot_outils, :text, unique: true
  end
end