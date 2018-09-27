require "rails_helper"
require 'pry'
RSpec.feature "Visit KOB Pool Play Page" do
  before do
    @player1 = User.create({ first_name: "Player1", last_name: "One",
                          email: "player1@example.com", password: 'password',
                          password_confirmation: 'password',
                          admin: true })
    @player2 = User.create({ first_name: "Player2", last_name: "Two",
                          email: "player2@example.com", password: 'password',
                          password_confirmation: 'password' })
    @player3 = User.create({ first_name: "Player3", last_name: "Three",
                          email: "player3@example.com", password: 'password',
                          password_confirmation: 'password' })
    @player4 = User.create({ first_name: "Player4", last_name: "Four",
                          email: "player4@example.com", password: 'password',
                          password_confirmation: 'password' })

    @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')
    Team.create(user_id: @player1.id, tournament_id: @tournament.id, team_name: @player1.first_name)
    Team.create(user_id: @player2.id, tournament_id: @tournament.id, team_name: @player2.first_name)
    Team.create(user_id: @player3.id, tournament_id: @tournament.id, team_name: @player3.first_name)
    Team.create(user_id: @player4.id, tournament_id: @tournament.id, team_name: @player4.first_name)

    visit '/'
    click_link("Log in", match: :first)
    fill_in "Email", with: @player1.email
    fill_in "Password", with: 'password'
    click_button "Log in"
    visit "/tournaments/#{@tournament.id}"
    click_link "Close Registration"
  end

  scenario "User tries to add a player(team) with closed registration" do
    visit "/tournaments/#{@tournament.id}/add_team"

    expect(page).to have_content("Registration is closed")
  end

  scenario "User starts pool play" do
    expect(page).to have_link("Open Registration")
    click_link "Start Pool Play"

    expect(page).to have_content("Start Pool Play")
    expect(page).to have_link("Create temporary pool")
    expect(current_path).to eq(new_poolplay_path(@tournament.id))

  end

  scenario "Enters pool play page after started" do
    click_link "Start Pool Play"
    click_link "Create temporary pool"
    click_link "Use this pool"
    visit "/tournaments/#{@tournament.id}"
    click_link "Pool Play"

    expect(page).to have_content("Player1")
    expect(page).to have_content("Player2")
    expect(page).to have_content("Player3")
    expect(page).to have_content("Player4")

  end

  scenario "Must have teams that are multiples of 4 to start pool play" do
    @player4.destroy
    Team.last.destroy
    click_link "Start Pool Play"

    expect(page).to have_content("You can not enter pool play")
    expect(current_path).to eq("/tournaments/#{@tournament.id}")
  end

  # scenario "user tries to enter pool play with less than 4 teams" do
  #   Team.last.destroy
  #   click_link "Pool Play"
  #
  #   expect(page).to have_content("You don't have enough teams for pool play")
  # end
end
