class AddFluencyScoreToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :word_count_correct, :integer
    add_column :sessions, :word_count_errors, :integer
    add_column :sessions, :word_count_omissions, :integer
    add_column :sessions, :mclm_score, :integer
    add_column :sessions, :word_alignment, :jsonb
  end
end
