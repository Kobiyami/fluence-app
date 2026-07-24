class ChangeDefaultAllowedTime < ActiveRecord::Migration[8.1]
  def change
    change_column_default :student_word_timings, :allowed_time, from: 8, to: 5
  end
end