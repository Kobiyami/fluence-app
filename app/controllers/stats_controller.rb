class StatsController < ApplicationController
  def index
    @students = Student.includes(:sessions, student_word_timings: :mot_outil).order(:last_name, :first_name)
  end
end