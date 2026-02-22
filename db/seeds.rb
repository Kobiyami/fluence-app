# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."
Student.destroy_all
Text.destroy_all
Session.destroy_all

puts "Creating students..."

students = [
  { first_name: "Alice", last_name: "Martin", code: "1234" },
  { first_name: "Benoît", last_name: "Durand", code: "2345" },
  { first_name: "Chloé", last_name: "Petit", code: "3456" },
  { first_name: "David", last_name: "Leroy", code: "4567" }
]

students.each do |data|
  Student.create!(data)
end

puts "Students created!"

puts "Creating texts..."

texts = [
  {
    title: "Le renard et le corbeau",
    content: "Maître Corbeau, sur un arbre perché, tenait en son bec un fromage...",
    word_count: 14
  },
  {
    title: "Le lièvre et la tortue",
    content: "Rien ne sert de courir ; il faut partir à point...",
    word_count: 12
  },
  {
    title: "Le petit chat",
    content: "Le petit chat joue dans le jardin et poursuit un papillon...",
    word_count: 15
  }
]

texts.each do |data|
  Text.create!(data)
end

puts "Texts created!"

puts "Creating a test session..."

Session.create!(
  student: Student.first,
  text: Text.first,
  duration_seconds: 45,
  score_wpm: (Text.first.word_count / (45.0 / 60)).round
)

puts "Test session created!"