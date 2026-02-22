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