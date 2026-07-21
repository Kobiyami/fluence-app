require "net/http"
require "json"

class FluencyScorer
  def initialize(reference_text, transcription, duration_seconds)
  @reference_original = tokenize(reference_text)
  @reference_words = normalize(reference_text)
  @transcribed_words = normalize(transcription)
  @duration_seconds = duration_seconds.to_f
end

  def call
    alignment = align(@reference_words, @transcribed_words)

    correct   = alignment.count { |a| a[:status] == "correct" }
    errors    = alignment.count { |a| a[:status] == "error" }
    omissions = alignment.count { |a| a[:status] == "omitted" }

    {
      word_count_correct:   correct,
      word_count_errors:    errors,
      word_count_omissions: omissions,
      mclm_score:           compute_mclm(correct, errors, omissions),
      word_alignment:       alignment
    }
  end

  private

  def normalize(text)
    # Supprimer les accents avant lemmatisation
  cleaned = text.unicode_normalize(:nfd).gsub(/\p{Mn}/, "")
    response = Net::HTTP.post(
      URI("http://localhost:5001/lemmatize"),
      { text: cleaned }.to_json,
      "Content-Type" => "application/json"
    )
    JSON.parse(response.body)["lemmas"]
  rescue => e
    Rails.logger.error "Lemmatizer service error: #{e.message}"
    text.downcase.gsub(/[^a-zàâéèêëîïôùûüç\s]/, "").split
  end

  def align(reference, transcribed)
    n = reference.length
    m = transcribed.length

    dp = Array.new(n + 1) { Array.new(m + 1, 0) }
    (0..n).each { |i| dp[i][0] = i }
    (0..m).each { |j| dp[0][j] = j }

    (1..n).each do |i|
      (1..m).each do |j|
        if reference[i-1] == transcribed[j-1]
          dp[i][j] = dp[i-1][j-1]
        else
          dp[i][j] = 1 + [dp[i-1][j], dp[i][j-1], dp[i-1][j-1]].min
        end
      end
    end

    backtrace(dp, reference, transcribed)
  end

  def backtrace(dp, reference, transcribed)
  i = reference.length
  j = transcribed.length
  result = []

  while i > 0 || j > 0
    if i > 0 && j > 0 && reference[i-1] == transcribed[j-1]
      result.unshift({ word: @reference_original[i-1], status: "correct" })
      i -= 1; j -= 1
    elsif i > 0 && j > 0 && dp[i][j] == dp[i-1][j-1] + 1
      result.unshift({ word: @reference_original[i-1], status: "error", heard: transcribed[j-1] })
      i -= 1; j -= 1
    elsif j > 0 && dp[i][j] == dp[i][j-1] + 1
      j -= 1
    else
      result.unshift({ word: @reference_original[i-1], status: "omitted" })
      i -= 1
    end
  end

  result
end

  def tokenize(text)
    text.gsub(/[^a-zA-ZÀ-ÿ\s]/, "").split
  end

  def compute_mclm(correct, errors, omissions)
    raw = [correct, 0].max
    if @duration_seconds > 0 && @duration_seconds < 60
      (raw * 60.0 / @duration_seconds).round
    else
      raw
    end
  end
end