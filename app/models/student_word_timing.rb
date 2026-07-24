class StudentWordTiming < ApplicationRecord
  PALIERS = [1, 1.5, 2, 3, 4, 5, 6, 8].freeze
  DEFAULT_ALLOWED_TIME = 5
  MIN_ALLOWED_TIME = PALIERS.first
  MAX_ALLOWED_TIME = PALIERS.last

  belongs_to :student
  belongs_to :mot_outil

  validates :allowed_time, inclusion: { in: PALIERS }
  validates :mot_outil_id, uniqueness: { scope: :student_id }

  def register_success!
    update!(allowed_time: PALIERS[current_index - 1] || MIN_ALLOWED_TIME, last_seen_at: Time.current)
  end

  def register_attempt!
    update!(allowed_time: PALIERS[current_index + 1] || MAX_ALLOWED_TIME, last_seen_at: Time.current)
  end

  # Durée réelle de la fenêtre d'enregistrement audio :
  # au moins 1.2s, même si le mot est affiché moins longtemps.
  def recording_duration
    [allowed_time.to_f, 1.2].max
  end

def ever_succeeded?
  StudentWordAttempt.exists?(student: student, mot_outil: mot_outil, correct: true)
end

def tier
  case allowed_time.to_f
  when 1, 1.5 then :top
  when 2, 3, 4 then :ok
  else :a_travailler
  end
end

  private

  def current_index
    PALIERS.index(allowed_time.to_f) || PALIERS.index(DEFAULT_ALLOWED_TIME)
  end
end