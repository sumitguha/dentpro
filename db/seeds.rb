# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

if RAILS_ENV == 'development'
  User.destroy_all
  User.create(:email => 'admin@dentpro.com', :password => 'ox4owg8yed4c', :password_confirmation => 'ox4owg8yed4c')
  u = User.find_by_email('admin@dentpro.com')
  u.email_confirmed = true
  u.save
end

