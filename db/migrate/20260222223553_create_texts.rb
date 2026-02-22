class CreateTexts < ActiveRecord::Migration[8.1]
  def change
    create_table :texts do |t|
      t.string :title
      t.text :content
      t.integer :word_count

      t.timestamps
    end
  end
end
