class StudentWordAttempt < ApplicationRecord
  belongs_to :student
  belongs_to :mot_outil

  def self.correct_per_minute_by_day(student)
    where(student: student, correct: true)
      .group_by { |a| a.created_at.to_date }
      .transform_values do |attempts|
        total_seconds = attempts.sum(&:allowed_time)
        next 0 if total_seconds.zero?
        (attempts.size / (total_seconds / 60.0)).round(1)
      end
  end
end