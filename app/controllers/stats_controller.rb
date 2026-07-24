class StatsController < ApplicationController
  def index
    @students = Student.includes(:sessions, student_word_timings: :mot_outil).order(:last_name, :first_name)
  end

  private

  def fluence_summary(student)
    sessions = student.sessions
      .where(status: "done", aborted: false)
      .where.not(mclm_score: nil)
      .includes(:reading_text)

    sessions.group_by(&:reading_text).map do |text, text_sessions|
      sorted = text_sessions.sort_by(&:created_at)
      numbered = sorted.each_with_index.map { |s, i| { session: s, number: i + 1 } }
      record = sorted.map(&:mclm_score).max
      latest = sorted.last

      trend = if latest.mclm_score >= record
                :progress
              elsif latest.mclm_score >= record * 0.95
                :stagnant
              else
                :regression
              end

      { text: text, latest: latest, record: record, trend: trend, attempts: numbered.reverse }
    end.sort_by { |h| h[:latest].created_at }.reverse
  end
  helper_method :fluence_summary
end