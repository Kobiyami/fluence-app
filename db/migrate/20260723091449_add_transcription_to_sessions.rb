class AddTranscriptionToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :transcription, :text
  end
end
