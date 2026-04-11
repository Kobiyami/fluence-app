puts "Cleaning database..."
Session.destroy_all
Student.destroy_all
ReadingText.destroy_all

puts "Creating students..."

students = [
  { first_name: "Alice", last_name: "Martin", code: "1234" },
  { first_name: "Benoît", last_name: "Durand", code: "2345" },
  { first_name: "Chloé", last_name: "Petit", code: "3456" },
  { first_name: "David", last_name: "Leroy", code: "4567" }
]

students.each { |data| Student.create!(data) }
puts "Students created!"

puts "Creating texts..."

texts = [
  {
    title: "Le renard et le corbeau",
    content: "Maître Corbeau, sur un arbre perché, tenait en son bec un fromage.",
    word_count: 14
  },
  {
    title: "Le lièvre et la tortue",
    content: "Rien ne sert de courir ; il faut partir à point.",
    word_count: 12
  },
  {
    title: "Le petit chat",
    content: "Le petit chat joue dans le jardin et poursuit un papillon.",
    word_count: 15
  },
  {
    title: "Le cirque",
    content: "Ce soir, Lisa et Amélie vont voir un spectacle de cirque avec leurs parents. Amélie espère qu'il y aura des animaux, des lions par exemple, ou même un éléphant. Lisa elle, attend avec impatience de voir les numéros des clowns. Il y a sûrement des clowns, dit papa, mais je ne suis pas certain que ce cirque ait un éléphant. Il paie les entrées, et la famille va s'installer au premier rang. Le spectacle commence par le numéro des acrobates qui font de grandes pyramides. Ensuite viennent les clowns. Lisa est enchantée. Pendant l'entracte, les filles se régalent avec de la bonne barbe à papa. Le spectacle reprend avec les trapézistes, et enfin les animaux tant attendus par Amélie. Il n'y a pas d'éléphant, mais un lion et des chevaux blancs qui galopent autour de la piste et se cabrent quand le dresseur le leur demande. Amélie et Lisa ont passé une très bonne soirée.",
    word_count: 162
  }
]

texts.each { |data| ReadingText.create!(data) }
puts "Texts created!"

puts "Done!"