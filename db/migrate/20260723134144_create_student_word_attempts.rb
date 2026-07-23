class CreateStudentWordAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :student_word_attempts do |t|
      t.references :student, null: false, foreign_key: true
      t.references :mot_outil, null: false, foreign_key: true
      t.boolean :correct
      t.integer :allowed_time

      t.timestamps
    end
  end
end
