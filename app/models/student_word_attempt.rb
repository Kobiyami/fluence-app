class StudentWordAttempt < ApplicationRecord
  belongs_to :student
  belongs_to :mot_outil

  def self.correct_per_minute_by_day(student)
    where(student: student)
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .pluck(Arel.sql("DATE(created_at)"), Arel.sql("ROUND(AVG(correct::int) * 100, 1)"))
      .to_h
  end
end
