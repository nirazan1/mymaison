# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create!(name: "Ram Thapa")
property = user.properties.create!([{name: "House 1", location: "kathmandu"},
                                    {name: "House 2", location: "pokhara"}])
reservation = Reservation.create!(property_id: Property.first.id)
guest = Guest.create!([{checkin_date: Time.current,
                        checkout_date: Time.current + 2.days,
                        name: "Raj",
                        surname: "Shrestha",
                        gender: "Male",
                        date_of_birth: Time.current - 30.years,
                        country_of_birth: "Nepal",
                        nationality: "Nepal",
                        passport_number: "12345",
                        group_leader: true,
                        email_address: 'rajshrestha@mailinator.com',
                        reservation_id: reservation.id
                      },
                      { checkin_date: Time.current,
                        checkout_date: Time.current + 2.days,
                        name: "Some",
                        surname: "Shrestha",
                        gender: "Female",
                        date_of_birth: Time.current - 31.years,
                        country_of_birth: "Nepal",
                        nationality: "Nepal",
                        group_leader: false,
                        reservation_id: reservation.id
                      }])
