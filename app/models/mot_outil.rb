class MotOutil < ApplicationRecord
  has_many :student_word_timings, dependent: :destroy

  validates :text, presence: true, uniqueness: { case_sensitive: false }
end