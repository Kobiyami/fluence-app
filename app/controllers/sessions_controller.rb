class SessionsController < ApplicationController
  def new
    @student = Student.find(params[:student_id]) if params[:student_id]
    @reading_text = ReadingText.find(params[:reading_text_id]) if params[:reading_text_id]
  end

  def start
    @session = Session.new(
      student_id: params[:student_id],
      reading_text_id: params[:reading_text_id]
    )

    unless @session.save
  Rails.logger.info @session.errors.full_messages.inspect
end


    @reading_text = ReadingText.find(params[:reading_text_id])

    render :start
  end

  def stop
    @session = Session.find(params[:session_id])
    @session.duration_seconds = params[:duration_seconds].to_i
    @session.aborted = params[:aborted] == "true"

    @session.compute_score!
    @session.save!

    redirect_to session_path(@session)
  end

  def show
    @session = Session.find(params[:id])
  end
end
