class Session < ApplicationRecord
  belongs_to :student
  belongs_to :reading_text, foreign_key: :text_id

  def compute_score!
    return if aborted?
    return if duration_seconds.to_i <= 0
    return if reading_text.blank?

    minutes = duration_seconds.to_f / 60
    self.score_wpm = (reading_text.word_count / minutes).round
  end
end