require "rails_helper"
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
    click_link("Log in")
    fill_in "Email", with: @player1.email
    fill_in "Password", with: 'password'
    click_button "Log in"
    visit "/tournaments/#{@tournament.id}"
    click_link "Close Registration"
    click_link "Start Pool Play"
    click_link "Create temporary pool"
    click_link "Use this pool"
  end

  # scenario "User computes result for first poolplay match" do
  #   visit poolplay_path(@tournament)
  #   expect(page).to have_link("Results", count: 3)
  #
  #   click_link "Results", match: :first
  #   expect(page).to have_content("Results for:")
  #   expect(page).to have_content("Score")
  #   expect(page).to have_content("Winner")
  # end
end
