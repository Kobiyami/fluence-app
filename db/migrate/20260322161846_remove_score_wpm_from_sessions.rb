class RemoveScoreWpmFromSessions < ActiveRecord::Migration[8.1]
  def change
    remove_column :sessions, :score_wpm, :integer
  end
end
