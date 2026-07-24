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
    record_completion = sorted.map(&:completion_rate).max
    latest = sorted.last

    trend = if latest.mclm_score >= record
              :progress
            elsif latest.mclm_score >= record * 0.95
              :stagnant
            else
              :regression
            end

    { text: text, latest: latest, record: record, record_completion: record_completion, trend: trend, attempts: numbered.reverse, attempts_chrono: numbered }
  end.sort_by { |h| h[:latest].created_at }.reverse
end
helper_method :fluence_summary
def first_attempts_chart(student)
  sessions = student.sessions
    .where(status: "done", aborted: false)
    .where.not(mclm_score: nil)
    .includes(:reading_text)

  first_attempts = sessions.group_by(&:reading_text).map do |text, text_sessions|
    text_sessions.min_by(&:created_at)
  end.sort_by(&:created_at)

  return nil if first_attempts.size < 2

  numbered = first_attempts.each_with_index.map { |s, i| { session: s, number: i + 1 } }
  attempts_chart_svg(numbered, labels: numbered.map { |a| a[:session].reading_text.title })
end
helper_method :first_attempts_chart
  def attempts_chart_svg(attempts, labels: nil)
  return nil if attempts.size < 2

  width = 320
  height = 130
  padding_left = 34
  padding_right = 34
  padding_top = 12
  padding_bottom = 20
  plot_width = width - padding_left - padding_right
  plot_height = height - padding_top - padding_bottom

  n = attempts.size
  step = plot_width.to_f / (n - 1)

  mclm_values = attempts.map { |a| a[:session].mclm_score || 0 }
  pct_values = attempts.map { |a| a[:session].completion_rate || 0 }

  mclm_marks = axis_marks(mclm_values)
  pct_marks = axis_marks(pct_values)

  mclm_points = attempts.each_with_index.map do |a, i|
    x = padding_left + i * step
    y = scale_y(a[:session].mclm_score || 0, mclm_marks, padding_top, plot_height)
    "#{x.round(1)},#{y.round(1)}"
  end.join(" ")

  pct_points = attempts.each_with_index.map do |a, i|
    x = padding_left + i * step
    y = scale_y(a[:session].completion_rate || 0, pct_marks, padding_top, plot_height)
    "#{x.round(1)},#{y.round(1)}"
  end.join(" ")

  x_labels = attempts.each_with_index.map do |a, i|
    x = padding_left + i * step
    text = labels ? labels[i].truncate(10) : a[:number].to_s
    "<text x=\"#{x.round(1)}\" y=\"#{height - 4}\" font-size=\"9\" text-anchor=\"middle\" fill=\"#2B2A28\">#{text}</text>"
  end.join

  left_axis = axis_label_svg(mclm_marks, padding_left - 6, "end", "#A65A3F", padding_top, plot_height, suffix: "")
  right_axis = axis_label_svg(pct_marks, padding_left + plot_width + 6, "start", "#3E6B3D", padding_top, plot_height, suffix: "%")

  <<~SVG.html_safe
    <svg viewBox="0 0 #{width} #{height}" class="attempt-chart">
      <line x1="#{padding_left}" y1="#{height - padding_bottom}" x2="#{width - padding_right}" y2="#{height - padding_bottom}" stroke="#E5E0D5" stroke-width="1" />
      <polyline points="#{mclm_points}" fill="none" stroke="#D97757" stroke-width="2" />
      <polyline points="#{pct_points}" fill="none" stroke="#5B8C5A" stroke-width="2" />
      #{x_labels}
      #{left_axis}
      #{right_axis}
    </svg>
  SVG
end
helper_method :attempts_chart_svg

def axis_marks(values)
  return [values.first] if values.min == values.max

  min_v = (values.min / 10.0).floor * 10
  max_v = (values.max / 10.0).ceil * 10
  mid_v = ((min_v + max_v) / 2.0).round
  [min_v, mid_v, max_v]
end

def scale_y(value, marks, padding_top, plot_height)
  return padding_top + plot_height * 0.25 if marks.size == 1

  min_v, max_v = marks.first, marks.last
  ratio = (value - min_v).to_f / (max_v - min_v)
  padding_top + plot_height - (ratio * plot_height)
end

def axis_label_svg(marks, x, anchor, color, padding_top, plot_height, suffix:)
  if marks.size == 1
    y = padding_top + plot_height * 0.25
    return "<text x=\"#{x}\" y=\"#{y.round(1) + 3}\" font-size=\"8\" font-weight=\"700\" text-anchor=\"#{anchor}\" fill=\"#{color}\">#{marks.first}#{suffix}</text>"
  end

  marks.reverse.each_with_index.map do |val, i|
    y = padding_top + i * (plot_height / 2.0)
    "<text x=\"#{x}\" y=\"#{y.round(1) + 3}\" font-size=\"8\" font-weight=\"700\" text-anchor=\"#{anchor}\" fill=\"#{color}\">#{val}#{suffix}</text>"
  end.join
end
  helper_method :attempts_chart_svg
end