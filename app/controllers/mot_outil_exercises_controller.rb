class MotOutilExercisesController < ApplicationController
  protect_from_forgery with: :null_session

  def play
  @student = Student.find(params[:student_id])
  @session_duration = params[:duration]&.to_i || 60

  words = if params[:categories].present?
            words_for_categories(@student, params[:categories])
          elsif params[:mot_outil_ids].present?
            MotOutil.where(id: params[:mot_outil_ids])
          else
            default_word_mix(@student)
          end

  @word_sequence = words.map do |mot|
    timing = StudentWordTiming.find_by(student: @student, mot_outil: mot)
    allowed = timing&.allowed_time&.to_f || StudentWordTiming::DEFAULT_ALLOWED_TIME
    recording = timing&.recording_duration || [allowed, 1.2].max
    { id: mot.id, text: mot.text, allowed_time: allowed, recording_duration: recording }
  end
end

  def transcribe_word
    student = Student.find(params[:student_id])
    mot_outil = MotOutil.find(params[:mot_outil_id])

    audio_path = Rails.root.join("tmp", "word_#{student.id}_#{mot_outil.id}_#{Time.now.to_i}_#{SecureRandom.hex(4)}.webm")
    File.binwrite(audio_path, params[:audio].read)

    wav_path = "#{audio_path}.wav"
    system("ffmpeg", "-y", "-i", audio_path.to_s, "-ar", "16000", "-ac", "1", wav_path, out: File::NULL, err: File::NULL)
if silent?(wav_path)
  render json: { mot_outil_id: mot_outil.id, text: mot_outil.text, correct: false, heard: "(rien entendu)" }
  return
end
    transcription = WhisperTranscriber.new(wav_path, model: :small).call
    correct = levenshtein(normalize(transcription), normalize(mot_outil.text)) <= 1

    wt = StudentWordTiming.find_or_create_by(student: student, mot_outil: mot_outil) do |t|
      t.allowed_time = StudentWordTiming::DEFAULT_ALLOWED_TIME
    end

    StudentWordAttempt.create!(student: student, mot_outil: mot_outil, correct: correct, allowed_time: wt.allowed_time)

    if correct
      wt.register_success!
    else
      wt.register_attempt!
    end

    render json: { mot_outil_id: mot_outil.id, text: mot_outil.text, correct: correct, heard: transcription.strip }
  end

def choose
  @student = Student.find(params[:student_id])
end

def pronounce
  path = WordPronouncer.new(params[:text]).call
  send_file path, type: "audio/wav", disposition: "inline"
end

  private

def default_word_mix(student)
  nouveaux = student.mots_nouveaux.to_a
  difficiles = student.mots_difficiles.map(&:mot_outil)
  maitrises = student.mots_maitrises.map(&:mot_outil).sample(2)

  (nouveaux + difficiles + maitrises).uniq.shuffle
end

def words_for_categories(student, categories)
  words = []
  words += student.mots_nouveaux.to_a if categories.include?("nouveaux")
  words += student.mots_difficiles.map(&:mot_outil) if categories.include?("difficiles")
  words += student.mots_a_consolider.map(&:mot_outil) if categories.include?("consolider")
  words += student.mots_maitrises.map(&:mot_outil) if categories.include?("maitrises")
  words.uniq.shuffle
end

  def normalize(text)
    cleaned = text.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "")
    cleaned.downcase.gsub(/[^a-z]/, "")
  end

  def levenshtein(a, b)
  return b.length if a.empty?
  return a.length if b.empty?

  costs = (0..b.length).to_a
  a.each_char.with_index do |ca, i|
    costs[0] = i + 1
    last = i
    b.each_char.with_index do |cb, j|
      temp = costs[j + 1]
      costs[j + 1] = ca == cb ? last : [costs[j], costs[j + 1], last].min + 1
      last = temp
    end
  end
  costs[b.length]
end

def silent?(wav_path)
  output = `ffmpeg -i #{wav_path} -af volumedetect -f null - 2>&1`
  match = output.match(/mean_volume:\s*(-?\d+\.?\d*)\s*dB/)
  match && match[1].to_f < -40.0
end

end