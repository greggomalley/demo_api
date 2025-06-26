# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# First, create all industries that might be needed
industry_names = ['Tech', 'Finance', 'Healthcare', 'Education', 'Manufacturing', 'Retail']
industry_names.each do |industry_name|
  Industry.find_or_create_by!(name: industry_name)
end

# Define user data with their associated industries
users_data = [
  { email_address: 'bob@example.com', password: 'password', industry_names: ['Tech', 'Finance', 'Education'] },
  { email_address: 'sarah@example.com', password: 'password', industry_names: ['Healthcare', 'Education'] },
  { email_address: 'gene@example.com', password: 'password', industry_names: ['Manufacturing', 'Retail'] }
]

users_data.each do |user_data|
  user = User.find_or_initialize_by(email_address: user_data[:email_address])
  user.password = user_data[:password]
  user.password_confirmation = user_data[:password]
  
  # Find the industry objects and associate them with the user
  industries = Industry.where(name: user_data[:industry_names])
  user.industries = industries
  
  user.save!
end
