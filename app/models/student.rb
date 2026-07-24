class Student < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :student_word_timings, dependent: :destroy
  validates :first_name, :last_name, :code, presence: true

  def name
    "#{first_name} #{last_name}"
  end
  def mots_nouveaux
  MotOutil.where.not(id: student_word_timings.select(:mot_outil_id)).order(:text)
end

def mots_difficiles
  student_word_timings.includes(:mot_outil).select { |t| t.tier == :a_travailler }.sort_by { |t| t.mot_outil.text }
end

def mots_a_consolider
  student_word_timings.includes(:mot_outil).select { |t| t.tier == :ok }.sort_by { |t| t.mot_outil.text }
end

def mots_maitrises
  student_word_timings.includes(:mot_outil).select { |t| t.tier == :top }.sort_by { |t| t.mot_outil.text }
end
end