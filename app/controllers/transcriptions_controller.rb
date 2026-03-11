class TranscriptionsController < ApplicationController
  protect_from_forgery with: :null_session  # indispensable pour fetch()

  def create
    file = params[:audio]

    if file.nil?
      Rails.logger.error "Aucun fichier reçu dans params[:audio]"
      render json: { error: "Aucun fichier reçu" }, status: 422
      return
    end

    # Sauvegarde temporaire
    path = Rails.root.join("tmp", file.original_filename)
    File.binwrite(path, file.read)

    # Appel Whisper
    begin
      text = WhisperTranscriber.new(path).call
    rescue => e
      Rails.logger.error "Erreur Whisper : #{e.message}"
      render json: { error: "Erreur Whisper" }, status: 500
      return
    end

    render json: { text: text }
  end
end
