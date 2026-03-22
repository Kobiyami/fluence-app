class Session < ApplicationRecord
  belongs_to :student
  belongs_to :reading_text

  attribute :aborted, :boolean, default: false
  attribute :transcription, :string

  def compute_score!
    return if aborted
    # Ton calcul actuel
  end
end
