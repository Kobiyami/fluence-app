class Session < ApplicationRecord
  belongs_to :student
  belongs_to :text

  before_save :compute_score

  private

  def compute_score
    return if duration_seconds.blank? || text.blank?

    self.score_wpm = (text.word_count / (duration_seconds.to_f / 60)).round
  end
end