# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.create(first_name: "Paul",
#             last_name: "OShea",
#             email: "poshea48@msn.com",
#             admin: true,
#             password: ,
#             )

# User.create!([
# {
#   first_name: "Dan",
#   last_name: ' ',
#   email: 'dan@email.com',
#   password: 'itsDan'
# },
# {
#   first_name: "Oliver",
#   last_name: " ",
#   email: 'oliver@email.com',
#   password: 'itsOliver'
# },
# {
#   first_name: "Mike",
#   last_name: ' ',
#   email: 'mike@email.com',
#   password: 'itsMike'
# },
# {
#   first_name: "Bobby",
#   last_name: " ",
#   email: 'bobby@email.com',
#   password: 'itsBobby'
# },
# {
#   first_name: "Chad",
#   last_name: ' ',
#   email: 'chad@email.com',
#   password: 'itsChad'
# },
# {
#   first_name: "Steve",
#   last_name: " ",
#   email: 'steve@email.com',
#   password: 'itsSteve'
# }])

Team.create!([
  {
    user_id: 1,
    tournament_id: 5,
    team_name: "Paul"
  },
  {
    user_id: 3,
    tournament_id: 5,
    team_name: "Abigail"
  },
  {
    user_id: 7,
    tournament_id: 5,
    team_name: "Dan"
  },
  {
    user_id: 9,
    tournament_id: 5,
    team_name: "Oliver"
  },
  {
    user_id: 10,
    tournament_id: 5,
    team_name: "Bobby"
  },
  {
    user_id: 11,
    tournament_id: 5,
    team_name: "Chad"
  },
  {
    user_id: 12,
    tournament_id: 5,
    team_name: "Steve"
  },
  {
    user_id: 1,
    tournament_id: 5,
    team_name: "Paul"
  }])
