class CreateStudentWordTimings < ActiveRecord::Migration[8.1]
  def change
    create_table :student_word_timings do |t|
      t.references :student, null: false, foreign_key: true
      t.references :mot_outil, null: false, foreign_key: true
      t.integer :allowed_time, null: false, default: 8
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :student_word_timings, [:student_id, :mot_outil_id], unique: true
  end
end