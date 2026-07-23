class FluencyAnalysisJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: "fluency_analysis"

  def perform(session_id, audio_path)
    session = Session.find(session_id)

    text = WhisperTranscriber.new(audio_path).call
    session.transcription = text

    scorer = FluencyScorer.new(session.reading_text.content, text, session.duration_seconds)
    session.assign_attributes(scorer.call)
    session.status = "done"
    session.save!
  rescue => e
    Rails.logger.error "FluencyAnalysisJob error: #{e.message}"
    session.update(status: "error") if session
  end
end