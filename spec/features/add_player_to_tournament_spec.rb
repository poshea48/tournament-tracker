require "rails_helper"

RSpec.feature "Add player" do
  before do
    @admin = User.create({ first_name: "Admin", last_name: "User",
                          email: "admin@example.com", password: 'password',
                          password_confirmation: 'password',
                          admin: true })

    @non_admin = User.create({ first_name: "Nonadmin", last_name: "User",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password' })

    @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')
    binding.pry
    visit '/'
    click_link("Log in")
    fill_in "Email", with: @admin.email
    fill_in "Password", with: 'password'
    click_button "Log in"
  end

  scenario "Admin user adds a player to a KOB tournament from index" do
    visit '/'
    click_link("Add", match: :first)
    expect(current_path).to eq("/tournaments/#{@tournament.id}/add_team")
    expect(page).to have_content("Admin")
    expect(page).to have_content("Nonadmin")

    check(@admin.first_name)
    check(@non_admin.first_name)

    click_button "Add Player(s)"

    expect(page).to have_content("Players added")
    expect(page).to have_content("#{@admin.first_name.capitalize}")
    expect(page).to have_content("#{@non_admin.first_name.capitalize}")

    expect(current_path).to eq(tournament_path(@tournament))
  end

  # scenario "Admin user adds a player to a KOB tournament from show" do
  # end

end
