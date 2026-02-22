class Text < ApplicationRecord
  has_many :sessions, dependent: :destroy

  validates :title, :content, :word_count, presence: true
end