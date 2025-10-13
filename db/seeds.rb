require 'faker'

puts "Cleaning database..."
Loan.destroy_all
Book.destroy_all
Author.destroy_all
Category.destroy_all
User.destroy_all

puts "Creating authors..."
10.times do
  Author.create!(
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    bio:        Faker::Lorem.paragraph(sentence_count: 5)
  )
end

puts "Creating categories..."
5.times do
  Category.create!(
    name: Faker::Book.genre,
    description: Faker::Lorem.sentence
  )
end

puts "Creating books..."
30.times do
  Book.create!(
    title:        Faker::Book.title,
    summary:      Faker::Lorem.paragraph(sentence_count: 3),
    published_at: Faker::Date.between(from: 10.years.ago, to: Date.today),
    author:       Author.all.sample,
    category:     Category.all.sample
  )
end

puts "Creating users..."
10.times do
  User.create!(
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    email:      Faker::Internet.email
  )
end

puts "Creating loans..."
20.times do
  Loan.create!(
    user: User.all.sample,
    book: Book.all.sample,
    borrowed_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
    returned_at: [nil, Faker::Date.between(from: 1.month.ago, to: Date.today)].sample
  )
end

puts "✅ Done! Created:"
puts "- #{Author.count} authors"
puts "- #{Category.count} categories"
puts "- #{Book.count} books"
puts "- #{User.count} users"
puts "- #{Loan.count} loans"

