class MotOutilExercisesController < ApplicationController
  protect_from_forgery with: :null_session

  def play
    @student = Student.find(params[:student_id])
    @session_duration = params[:duration]&.to_i || 60
    words = MotOutil.order(:created_at)

    @word_sequence = words.map do |mot|
      timing = StudentWordTiming.find_by(student: @student, mot_outil: mot)
      { id: mot.id, text: mot.text, allowed_time: timing&.allowed_time || StudentWordTiming::DEFAULT_ALLOWED_TIME }
    end
  end

  def transcribe_word
    student = Student.find(params[:student_id])
    mot_outil = MotOutil.find(params[:mot_outil_id])

    audio_path = Rails.root.join("tmp", "word_#{student.id}_#{mot_outil.id}_#{Time.now.to_i}_#{SecureRandom.hex(4)}.webm")
    File.binwrite(audio_path, params[:audio].read)

    wav_path = "#{audio_path}.wav"
    system("ffmpeg", "-y", "-i", audio_path.to_s, "-ar", "16000", "-ac", "1", wav_path, out: File::NULL, err: File::NULL)

    transcription = WhisperTranscriber.new(wav_path, model: :small).call
    correct = levenshtein(normalize(transcription), normalize(mot_outil.text)) <= 1

    wt = StudentWordTiming.find_or_create_by(student: student, mot_outil: mot_outil) do |t|
      t.allowed_time = StudentWordTiming::DEFAULT_ALLOWED_TIME
    end

    if correct
      wt.register_success!
    else
      wt.register_attempt!
    end

    render json: { mot_outil_id: mot_outil.id, text: mot_outil.text, correct: correct, heard: transcription.strip }
  end

def pronounce
  path = WordPronouncer.new(params[:text]).call
  send_file path, type: "audio/wav", disposition: "inline"
end

  private

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
end