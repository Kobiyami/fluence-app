class WordPronouncer
  def initialize(text)
    @text = text
  end

  def call
    piper_bin = Rails.root.join("app/services/piper/piper/piper").to_s
    model_path = Rails.root.join("app/services/piper/fr_FR-siwis-medium.onnx").to_s

    raise "Piper introuvable : #{piper_bin}" unless File.exist?(piper_bin)
    raise "Modèle voix introuvable : #{model_path}" unless File.exist?(model_path)

    timestamp = Time.now.strftime("%Y%m%d_%H%M%S%L")
    output_path = Rails.root.join("tmp", "pronunciations", "word_#{timestamp}.wav").to_s
    FileUtils.mkdir_p(File.dirname(output_path))

    IO.popen([piper_bin, "--model", model_path, "--output_file", output_path], "w") do |io|
      io.puts(@text)
    end

    output_path
  end
end