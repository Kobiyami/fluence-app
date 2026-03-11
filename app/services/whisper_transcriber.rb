class WhisperTranscriber
  def initialize(audio_path)
    @audio_path = audio_path
    @whisper_bin = Rails.root.join("app/services/whisper/whisper").to_s
    @model_path = Rails.root.join("app/services/whisper/ggml-large-v3.bin").to_s
  end

  def call
    wav = convert_to_wav(@audio_path)

    # Vérifications préalables
      raise "Binaire whisper introuvable : #{@whisper_bin}" unless File.exist?(@whisper_bin)
      raise "Modèle introuvable : #{@model_path}" unless File.exist?(@model_path)
      raise "Fichier WAV introuvable : #{wav}" unless File.exist?(wav)

    # 1. Générer un nom unique pour le fichier texte
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    base = Rails.root.join("tmp", "transcriptions", "transcription_#{timestamp}").to_s
    output_path = "#{base}.txt"

    # 2. Créer le fichier avec un contenu par défaut
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, "Aucune transcription")

    puts "=== COMMANDE WHISPER ==="
    puts "#{@whisper_bin} -m #{@model_path} -f #{wav} -l fr -otxt -of #{base}"
    puts "========================="

    # 3. Lancer Whisper pour écraser ce fichier
    success = system(
    @whisper_bin, "-m", @model_path, "-f", wav,
    "-l", "fr", "-t", "4", "-otxt", "-of", base
  )

  Rails.logger.info "Whisper exit success: #{success}"
  Rails.logger.info "Fichier généré : #{File.exist?(output_path)}"
  Rails.logger.info "Contenu : #{File.read(output_path)}"

    # 4. Lire le fichier (il existe toujours)
    File.read(output_path)
  end

  private

  def convert_to_wav(path)
    wav_path = path.to_s.sub(/\.\w+$/, ".converted.wav")

    system("ffmpeg", "-y", "-i", path.to_s, "-ar", "16000", "-ac", "1", wav_path)

    wav_path
  end
end
