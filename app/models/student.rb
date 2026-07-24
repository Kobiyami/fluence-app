class Student < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :student_word_timings, dependent: :destroy
  validates :first_name, :last_name, :code, presence: true

  def name
    "#{first_name} #{last_name}"
  end
  def mots_nouveaux
  MotOutil.where.not(id: student_word_timings.select(:mot_outil_id))
end

def mots_difficiles
  student_word_timings.includes(:mot_outil).select { |t| t.tier == :a_travailler }
end

def mots_a_consolider
  student_word_timings.includes(:mot_outil).select { |t| t.tier == :ok }
end

def mots_maitrises
  student_word_timings.includes(:mot_outil).select { |t| t.tier == :top }
end
end