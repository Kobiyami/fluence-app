class WhisperTranscriber
  def initialize(audio_path)
    @audio_path  = audio_path
    @whisper_bin = Rails.root.join("app/services/whisper/whisper")
    @model_path  = Rails.root.join("app/services/whisper/ggml-small.bin")
  end

  def call
    wav = convert_to_wav(@audio_path)

    base = wav.to_s.sub(/\.\w+$/, '')
    output_path = "#{base}.txt"

    system(
      @whisper_bin.to_s,
      "-m", @model_path.to_s,
      "-f", wav.to_s,
      "-otxt",
      "-of", base
    )

    File.read(output_path)
  end

  private

  def convert_to_wav(path)
    wav_path = path.to_s.sub(/\.\w+$/, ".wav")
    system("ffmpeg", "-y", "-i", path.to_s, wav_path)
    wav_path
  end
end
