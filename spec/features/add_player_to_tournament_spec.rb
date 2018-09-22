require "rails_helper"

RSpec.feature "Add player" do
  before do
    @admin = User.create({ first_name: "Admin", last_name: "User",
                          email: "admin@example.com", password: 'password',
                          password_confirmation: 'password',
                          admin: true })

    @non_admin = User.create({ first_name: "Non-admin", last_name: "User",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password' })

    @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')

    visit '/'
    click_link("Log in", match: :first)
    fill_in "Email", with: @admin.email
    fill_in "Password", with: 'password'
    click_button "Log in"
  end

  scenario "Admin user adds a player to a KOB tournament from index" do
    visit '/'
    click_link("Add", match: :first)

    expect(current_path).to eq("/tournaments/#{@tournament.id}/edit/join")
    expect(page).to have_content("Player info")
    expect(page).not_to have_content("Player 1 info")
    expect(page).not_to have_content("Player 2 info")

    fill_in "First name", with: @admin.first_name
    fill_in "Last name", with: @admin.last_name
    fill_in "Email", with: @admin.email
    click_button "Add Player"

    expect(page).to have_content("Player has been added")
    expect(page).to have_content("#{@admin.first_name.capitalize} #{@admin.last_name.capitalize}")
    expect(current_path).to eq(tournament_path(@tournament))
  end

  # scenario "Admin user adds a player to a KOB tournament from show" do
  # end

end
