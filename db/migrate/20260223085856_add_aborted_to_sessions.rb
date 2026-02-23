class AddAbortedToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :aborted, :boolean, default: false, null: false
  end
end