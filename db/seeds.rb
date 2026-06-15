# Clear existing data
puts "Clearing existing data..."
Note.destroy_all
ProviderAssignment.destroy_all
Client.destroy_all
Provider.destroy_all

puts "Creating TV doctor providers..."
providers = [
  Provider.create!(name: "Dr. Gregory House", email: "house@princeton-plainsboro.com"),
  Provider.create!(name: "Dr. Christina Yang", email: "christina.yang@greyssloan.com"),
  Provider.create!(name: "Dr. John Dorian", email: "jd@sacredheart.com"),
  Provider.create!(name: "Dr. Michael Robinavitch", email: "dr.robby@thepitt.com")
]

puts "Creating superhero clients..."
clients = [
  Client.create!(name: "Bruce Wayne", email: "batman@wayneenterprises.com"),
  Client.create!(name: "Peter Parker", email: "spiderman@dailybugle.com"),
  Client.create!(name: "Diana Prince", email: "wonderwoman@themyscira.com"),
  Client.create!(name: "Tony Stark", email: "ironman@starkindustries.com"),
  Client.create!(name: "Natasha Romanoff", email: "blackwidow@shield.gov"),
  Client.create!(name: "Clark Kent", email: "superman@dailyplanet.com"),
  Client.create!(name: "Steve Rogers", email: "captainamerica@shield.gov"),
  Client.create!(name: "Wanda Maximoff", email: "scarletwitch@avengers.com")
]

puts "Creating provider-client assignments..."
# Dr. House has 4 patients (all premium because he's expensive)
ProviderAssignment.create!(provider: providers[0], client: clients[0], plan: :premium)
ProviderAssignment.create!(provider: providers[0], client: clients[3], plan: :premium)
ProviderAssignment.create!(provider: providers[0], client: clients[5], plan: :premium)
ProviderAssignment.create!(provider: providers[0], client: clients[6], plan: :premium)

# Dr. Yang has 3 patients (mix of plans)
ProviderAssignment.create!(provider: providers[1], client: clients[1], plan: :basic)
ProviderAssignment.create!(provider: providers[1], client: clients[2], plan: :premium)
ProviderAssignment.create!(provider: providers[1], client: clients[7], plan: :basic)

# Dr. JD has 3 patients
ProviderAssignment.create!(provider: providers[2], client: clients[0], plan: :basic)
ProviderAssignment.create!(provider: providers[2], client: clients[4], plan: :premium)
ProviderAssignment.create!(provider: providers[2], client: clients[6], plan: :basic)

# Dr. Robby has 4 patients
ProviderAssignment.create!(provider: providers[3], client: clients[2], plan: :premium)
ProviderAssignment.create!(provider: providers[3], client: clients[3], plan: :basic)
ProviderAssignment.create!(provider: providers[3], client: clients[5], plan: :premium)
ProviderAssignment.create!(provider: providers[3], client: clients[7], plan: :basic)

puts "Creating superhero health notes..."
# Batman's notes
Note.create!(client: clients[0], content: "Bruised ribs from rooftop encounter. Advised rest but patient insists on patrol tonight.", created_at: 5.days.ago)
Note.create!(client: clients[0], content: "Alfred reports patient sleeping only 3 hours per night. Discussed importance of recovery time.", created_at: 3.days.ago)
Note.create!(client: clients[0], content: "Patient requested stronger painkillers. Declined. Suggested meditation instead. Patient seemed skeptical.", created_at: 1.day.ago)

# Spider-Man's notes
Note.create!(client: clients[1], content: "Web-slinging causing repetitive strain in shoulders. Prescribed physical therapy exercises.", created_at: 7.days.ago)
Note.create!(client: clients[1], content: "Patient worried about revealing identity during MRI. Assured complete confidentiality.", created_at: 4.days.ago)
Note.create!(client: clients[1], content: "Spider-sense causing headaches. No medical explanation found. Recommended stress management.", created_at: 2.days.ago)

# Wonder Woman's notes
Note.create!(client: clients[2], content: "Routine checkup. Patient in excellent health. Amazonian physiology continues to fascinate.", created_at: 10.days.ago)
Note.create!(client: clients[2], content: "Minor lasso burn on wrist. Patient declined treatment, stated it will heal by tomorrow.", created_at: 6.days.ago)

# Iron Man's notes
Note.create!(client: clients[3], content: "Arc reactor check. Power levels stable. Patient made joke about his 'heart'. Classic deflection.", created_at: 8.days.ago)
Note.create!(client: clients[3], content: "Discussed reducing caffeine intake. Patient laughed and said 'that's not going to happen.'", created_at: 5.days.ago)
Note.create!(client: clients[3], content: "Anxiety levels elevated. Recommended therapy. Patient said he has 'Pepper for that.'", created_at: 1.day.ago)

# Black Widow's notes
Note.create!(client: clients[4], content: "Treating various contusions. Patient refused to explain how injuries occurred. 'Classified.'", created_at: 9.days.ago)
Note.create!(client: clients[4], content: "Follow-up on previous injuries. Healing faster than expected. Impressive recovery rate.", created_at: 4.days.ago)

# Superman's notes
Note.create!(client: clients[5], content: "Patient exposed to kryptonite. Monitored overnight. Full recovery by morning.", created_at: 12.days.ago)
Note.create!(client: clients[5], content: "Advised patient to take occasional break from heroics. Patient smiled and said 'I'll think about it.'", created_at: 6.days.ago)
Note.create!(client: clients[5], content: "Hearing check. Patient can hear conversations in neighboring state. Recommended noise-canceling.", created_at: 2.days.ago)

# Captain America's notes
Note.create!(client: clients[6], content: "Super soldier serum continues to maintain peak physical condition. Remarkable.", created_at: 11.days.ago)
Note.create!(client: clients[6], content: "Patient inquired about modern nutrition trends. Provided overview. Still prefers 1940s diet.", created_at: 5.days.ago)
Note.create!(client: clients[6], content: "Shield arm showing signs of strain. Recommended strength training adjustments.", created_at: 3.days.ago)

# Scarlet Witch's notes
Note.create!(client: clients[7], content: "Chaos magic causing energy fluctuations. Monitoring for any adverse health effects.", created_at: 8.days.ago)
Note.create!(client: clients[7], content: "Patient experiencing nightmares. Discussed trauma-informed care options.", created_at: 4.days.ago)
Note.create!(client: clients[7], content: "Mental health check-in. Patient making good progress with coping strategies.", created_at: 1.day.ago)

puts "\n✅ Seed data created successfully!"
puts "\n" + "="*60
puts "TV DOCTORS (Providers):"
providers.each { |p| puts "  - #{p.name} (ID: #{p.id})" }
puts "\nSUPERHERO PATIENTS (Clients):"
clients.each { |c| puts "  - #{c.name} (ID: #{c.id})" }
puts "\nSTATS:"
puts "  - #{Provider.count} providers"
puts "  - #{Client.count} clients"
puts "  - #{ProviderAssignment.count} provider-client assignments"
puts "  - #{Note.count} health notes"
puts "="*60
