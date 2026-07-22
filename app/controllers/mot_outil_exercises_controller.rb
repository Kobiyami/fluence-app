class MotOutilExercisesController < ApplicationController
  def play
    @student = Student.find(params[:student_id])
    words = MotOutil.order(:created_at)

    @word_sequence = words.map do |mot|
      timing = StudentWordTiming.find_by(student: @student, mot_outil: mot)
      { id: mot.id, text: mot.text, allowed_time: timing&.allowed_time || StudentWordTiming::DEFAULT_ALLOWED_TIME }
    end
  end

  def pronounce
    path = WordPronouncer.new(params[:text]).call
    send_file path, type: "audio/wav", disposition: "inline"
  end
  
  def finish
    student = Student.find(params[:student_id])

    audio_data = params[:audio_file].split(",").last
    audio_binary = Base64.decode64(audio_data)
    full_path = Rails.root.join("tmp", "mots_outils_#{student.id}_#{Time.now.to_i}.webm")
    File.binwrite(full_path, audio_binary)

    results = params[:word_timings].map do |timing|
      segment_path = extract_segment(full_path, timing["start"], timing["end"])
      transcription = WhisperTranscriber.new(segment_path, model: :small).call
      correct = normalize(transcription) == normalize(timing["text"])

      mot_outil = MotOutil.find(timing["mot_outil_id"])
      wt = StudentWordTiming.find_or_create_by(student: student, mot_outil: mot_outil) do |t|
        t.allowed_time = StudentWordTiming::DEFAULT_ALLOWED_TIME
      end

      if correct
        wt.register_success!
      else
        wt.register_attempt!
      end

      { mot_outil_id: mot_outil.id, text: mot_outil.text, correct: correct, heard: transcription.strip }
    end

    render json: { results: results }
  end

  private

  def extract_segment(full_path, start_sec, end_sec)
  duration = end_sec.to_f - start_sec.to_f
  out_path = "#{full_path}.#{start_sec}.wav"
  system("ffmpeg", "-y", "-i", full_path.to_s, "-ss", start_sec.to_s, "-t", duration.to_s,
         "-ar", "16000", "-ac", "1", out_path, out: File::NULL, err: File::NULL)
  out_path
end

  def normalize(text)
    cleaned = text.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "")
    cleaned.downcase.gsub(/[^a-z]/, "")
  end
end