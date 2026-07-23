class SessionsController < ApplicationController

  def new
    @student = Student.find(params[:student_id])
    @reading_text = ReadingText.find(params[:reading_text_id])
  end

  def start
    @session = Session.create!(
      student_id: params[:student_id],
      reading_text_id: params[:reading_text_id]
    )

    @reading_text = ReadingText.find(params[:reading_text_id])
    render :start
  end

  def stop
  @session = Session.find(params[:session_id])
  @session.duration_seconds = params[:duration_seconds].to_i
  @session.aborted = params[:aborted] == "true"

  if !@session.aborted && params[:audio_file].present?
    audio_data = params[:audio_file].split(",").last
    audio_binary = Base64.decode64(audio_data)
    path = Rails.root.join("tmp", "session_#{@session.id}.webm")
    File.binwrite(path, audio_binary)

    @session.status = "processing"
    @session.save!
    FluencyAnalysisJob.perform_later(@session.id, path.to_s)
  else
    @session.status = "done"
    @session.save!
  end

  redirect_to session_path(@session)
end

  def show
    @session = Session.find(params[:id])
  end
end
