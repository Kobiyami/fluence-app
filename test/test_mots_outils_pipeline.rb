# Test reproductible du pipeline mots outils, sans navigateur ni micro.
# Génère l'audio avec Piper (voix connue, silence contrôlé), simule le
# découpage exact que fait le contrôleur, puis transcrit et compare.
#
# Lancer avec : bin/rails runner test/test_mots_outils_pipeline.rb

require "fileutils"

PIPER_BIN   = Rails.root.join("app/services/piper/piper/piper").to_s
PIPER_MODEL = Rails.root.join("app/services/piper/fr_FR-siwis-medium.onnx").to_s
WORK_DIR    = Rails.root.join("tmp", "test_mots_outils").to_s

FileUtils.rm_rf(WORK_DIR)
FileUtils.mkdir_p(WORK_DIR)

WORDS = ["les", "dans", "avec", "sur"]
ALLOWED_TIME = 8 # secondes, comme le temps par défaut réel

def normalize(text)
  cleaned = text.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "")
  cleaned.downcase.gsub(/[^a-z]/, "")
end

def run(cmd)
  system(*cmd, out: File::NULL, err: File::NULL)
end

# 1. Générer un clip par mot avec Piper, puis le padder au format
#    "mot + silence jusqu'à ALLOWED_TIME", exactement comme un vrai essai.
padded_clips = WORDS.map do |word|
  raw_path = File.join(WORK_DIR, "#{word}_raw.wav")
  padded_path = File.join(WORK_DIR, "#{word}_padded.wav")

  IO.popen([PIPER_BIN, "--model", PIPER_MODEL, "--output_file", raw_path], "w") { |io| io.puts(word) }

  run([
    "ffmpeg", "-y", "-i", raw_path,
    "-af", "apad=whole_dur=#{ALLOWED_TIME}",
    "-t", ALLOWED_TIME.to_s,
    "-ar", "16000", "-ac", "1",
    padded_path
  ])

  padded_path
end

# 2. Concaténer tous les clips paddés en un seul fichier, comme le ferait
#    l'enregistrement continu du navigateur.
concat_list = File.join(WORK_DIR, "concat_list.txt")
File.write(concat_list, padded_clips.map { |p| "file '#{p}'" }.join("\n"))

full_audio = File.join(WORK_DIR, "full.wav")
run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", concat_list, "-c", "copy", full_audio])

# 3. Construire les timings, comme le ferait le JS (start/end en secondes
#    depuis le début de l'enregistrement).
word_timings = WORDS.each_with_index.map do |word, i|
  { text: word, start: i * ALLOWED_TIME, end: (i + 1) * ALLOWED_TIME }
end

# 4. Reproduire exactement extract_segment + WhisperTranscriber du contrôleur.
def extract_segment(full_path, start_sec, end_sec)
  duration = end_sec.to_f - start_sec.to_f
  out_path = "#{full_path}.#{start_sec}.wav"
  system("ffmpeg", "-y", "-i", full_path.to_s, "-ss", start_sec.to_s, "-t", duration.to_s,
         "-ar", "16000", "-ac", "1", out_path, out: File::NULL, err: File::NULL)
  out_path
end

puts "=" * 60
puts "TEST PIPELINE MOTS OUTILS (#{WORDS.length} mots, #{ALLOWED_TIME}s chacun)"
puts "=" * 60

results = word_timings.map do |timing|
  segment_path = extract_segment(full_audio, timing[:start], timing[:end])

  started_at = Time.now
  transcription = WhisperTranscriber.new(segment_path, model: :small).call
  elapsed = (Time.now - started_at).round(1)

  correct = normalize(transcription) == normalize(timing[:text])

  status = correct ? "OK" : "FAIL"
  puts "[#{status}] attendu=\"#{timing[:text]}\" obtenu=\"#{transcription.strip}\" (#{elapsed}s)"

  { word: timing[:text], correct: correct, heard: transcription.strip, elapsed: elapsed }
end

puts "-" * 60
ok_count = results.count { |r| r[:correct] }
puts "#{ok_count}/#{results.length} corrects — temps total : #{results.sum { |r| r[:elapsed] }.round(1)}s"