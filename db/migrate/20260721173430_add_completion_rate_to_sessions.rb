class AddCompletionRateToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :completion_rate, :integer
  end
end
