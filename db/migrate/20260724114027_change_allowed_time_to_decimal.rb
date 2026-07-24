class ChangeAllowedTimeToDecimal < ActiveRecord::Migration[8.1]
  def change
    change_column :student_word_timings, :allowed_time, :decimal, precision: 3, scale: 1
    change_column :student_word_attempts, :allowed_time, :decimal, precision: 3, scale: 1
  end
end