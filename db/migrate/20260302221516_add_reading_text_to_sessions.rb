class AddReadingTextToSessions < ActiveRecord::Migration[8.1]
  def change
    add_reference :sessions, :reading_text, null: false, foreign_key: true
  end
end
