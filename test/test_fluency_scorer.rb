# Stub minimal pour éviter de charger tout Rails (pas besoin de la BDD pour ce test)
module Rails
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
require "logger"

require_relative "../app/services/fluency_scorer"

def run_case(name, reference, transcription, duration, expected)
  scorer = FluencyScorer.new(reference, transcription, duration)
  result = scorer.call

  puts "=" * 60
  puts "CAS : #{name}"
  puts "-" * 60
  puts "Référence     : #{reference}"
  puts "Transcription : #{transcription}"
  puts
  puts "Corrects   : #{result[:word_count_correct]}   (attendu: #{expected[:correct]})"
  puts "Erreurs    : #{result[:word_count_errors]}   (attendu: #{expected[:errors]})"
  puts "Omissions  : #{result[:word_count_omissions]}   (attendu: #{expected[:omissions]})"
  puts "MCLM actuel (formule du code)      : #{result[:mclm_score]}"

  standard_mclm = duration > 0 && duration < 60 ? (result[:word_count_correct] * 60.0 / duration).round : result[:word_count_correct]
  puts "MCLM standard (= correct/durée*60) : #{standard_mclm}"

  ok = result[:word_count_correct] == expected[:correct] &&
       result[:word_count_errors] == expected[:errors] &&
       result[:word_count_omissions] == expected[:omissions]
  puts ok ? ">>> ALIGNEMENT OK" : ">>> ALIGNEMENT KO — voir détail ci-dessous"

  puts
  puts "Détail alignement :"
  result[:word_alignment].each do |a|
    marker = case a[:status]
             when "correct" then "  "
             when "error"   then "X "
             when "omitted" then "-  "
             end
    extra = a[:heard] ? " (entendu: #{a[:heard]})" : ""
    puts "#{marker}#{a[:word]}#{extra} [#{a[:status]}]"
  end
  puts
end

reference = "Le chat noir dort sur le tapis rouge de la maison"

# Cas A — transcription parfaite
run_case(
  "Transcription parfaite",
  reference,
  "Le chat noir dort sur le tapis rouge de la maison",
  60.0,
  { correct: 11, errors: 0, omissions: 0 }
)

# Cas B — un mot oublié au milieu (teste le réalignement après omission)
run_case(
  "Mot oublié (tapis)",
  reference,
  "Le chat noir dort sur le rouge de la maison",
  60.0,
  { correct: 10, errors: 0, omissions: 1 }
)

# Cas C — bégaiement (mot répété), ne doit pas être pénalisé
run_case(
  "Bégaiement (chat répété)",
  reference,
  "Le chat chat noir dort sur le tapis rouge de la maison",
  60.0,
  { correct: 11, errors: 0, omissions: 0 }
)

# Cas D — ligne sautée (plusieurs mots d'affilée), teste le réalignement après un gros trou
run_case(
  "Ligne sautée (sur le tapis rouge)",
  reference,
  "Le chat noir dort de la maison",
  60.0,
  { correct: 7, errors: 0, omissions: 4 }
)

# Cas E — substitution (mot remplacé par un autre)
run_case(
  "Substitution (noir -> blanc)",
  reference,
  "Le chat blanc dort sur le tapis rouge de la maison",
  60.0,
  { correct: 10, errors: 1, omissions: 0 }
)

# Cas F — apostrophes (teste la désynchronisation tokenize/normalize)
run_case(
  "Élision (l'enfant, qu'il)",
  "L'enfant qu'il regarde traverse la rue",
  "L'enfant qu'il regarde traverse la rue",
  60.0,
  { correct: 6, errors: 0, omissions: 0 }
)

# Cas G — lecture interrompue tôt (filoutage), teste completion_rate
scorer = FluencyScorer.new(
  "Le chat noir dort sur le tapis rouge de la maison",
  "Le chat noir",
  2.0
)
result = scorer.call
puts "=" * 60
puts "CAS : Lecture interrompue tôt (3 mots sur 11)"
puts "-" * 60
puts "MCLM : #{result[:mclm_score]}"
puts "Completion : #{result[:completion_rate]}%"
puts result[:completion_rate] < 50 ? ">>> COMPLETION OK (faible, comme attendu)" : ">>> PROBLEME"