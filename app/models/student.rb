class Student < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :student_word_timings, dependent: :destroy
  validates :first_name, :last_name, :code, presence: true

  def name
    "#{first_name} #{last_name}"
  end
end