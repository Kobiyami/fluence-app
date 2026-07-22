class StudentWordTiming < ApplicationRecord
  MIN_ALLOWED_TIME = 2
  DEFAULT_ALLOWED_TIME = 8

  belongs_to :student
  belongs_to :mot_outil

  validates :allowed_time, numericality: { greater_than_or_equal_to: MIN_ALLOWED_TIME }
  validates :mot_outil_id, uniqueness: { scope: :student_id }

  def register_success!
    update!(allowed_time: [allowed_time - 1, MIN_ALLOWED_TIME].max, last_seen_at: Time.current)
  end

  def register_attempt!
    update!(last_seen_at: Time.current)
  end
end