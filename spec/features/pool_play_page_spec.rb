require "rails_helper"

RSpec.feature "Visit KOB Pool Play Page" do
  before do
    @player1 = User.create({ first_name: "Player", last_name: "One",
                          email: "player1@example.com", password: 'password',
                          password_confirmation: 'password',
                          admin: true })

    @player2 = User.create({ first_name: "Player", last_name: "Two",
                          email: "player2@example.com", password: 'password',
                          password_confirmation: 'password' })
    @player3 = User.create({ first_name: "Player", last_name: "Three",
                          email: "player3@example.com", password: 'password',
                          password_confirmation: 'password' })
    @player4 = User.create({ first_name: "Player", last_name: "Four",
                          email: "player4@example.com", password: 'password',
                          password_confirmation: 'password' })

    @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')
    Team.create(user_id: @player1.id, tournament_id: @tournament.id, team_name: "Player One")
    Team.create(user_id: @player2.id, tournament_id: @tournament.id, team_name: "Player Two")
    Team.create(user_id: @player3.id, tournament_id: @tournament.id, team_name: "Player Three")
    Team.create(user_id: @player4.id, tournament_id: @tournament.id, team_name: "Player Four")

    visit '/'
    click_link("Log in", match: :first)
    fill_in "Email", with: @player1.email
    fill_in "Password", with: 'password'
    click_button "Log in"
    visit "/tournaments/#{@tournament.id}"
    click_link "Close Registration"
  end

  scenario "User tries to enter pool play with open registration" do
    click_link "Open Registration"
    click_link "Pool Play"

    expect(page).to have_link("Close Registration")
    expect(page).to have_content("You can not enter, registration is still open")
  end

  scenario "User enters pool play successfully" do
    expect(page).to have_link("Open Registration")
    click_link "Pool Play"

    expect(current_path).to eq(pool_play_path(@tournament.id))
  end

  scenario "Enters pool play page with all matchups" do
    click_link "Pool Play"

    expect(page).to have_content("Player One/Player Four vs Player Two/Player Three")
    expect(page).to have_content("Player One/Player Three vs Player Two/Player Four")
    expect(page).to have_content("Player One/Player Two vs Player Three/Player Four")
  end
end
