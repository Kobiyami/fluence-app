class Session < ApplicationRecord
  belongs_to :student
  belongs_to :text

  def compute_score!
  return if aborted?
  return if duration_seconds.to_i <= 0
  return if text.blank?

  minutes = duration_seconds.to_f / 60
  self.score_wpm = (text.word_count / minutes).round
  end
end