require "rails_helper"

RSpec.feature "Close Registration" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')
    @admin = User.create({ first_name: "Admin", last_name: "User",
                          email: "admin@example.com", password: 'password',
                          password_confirmation: 'password',
                          admin: true })

    @non_admin = User.create({ first_name: "Non-admin", last_name: "User",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password' })

    visit '/'
    click_link "Log in"
    fill_in "Email", with: @admin.email
    fill_in "Password", with: 'password'
    click_button "Log in"
  end

  # scenario "Admin unsuccessfully closes registration" do
  #   visit '/'
  #   click_link @tournament.name
  #
  #   click_link "Close Registration"
  #   expect(page).to have_content("You can not close an empty Tournament")
  #   expect(current_path).to eq(tournament_path(@tournament))
  # end

  scenario "Admin closes registration successfully" do
    Team.create(user_id: @admin.id, tournament_id: @tournament.id)
    Team.create(user_id: @non_admin.id, tournament_id: @tournament.id)
    visit '/'
    click_link @tournament.name
    expect(page).to have_link("Add Player")
    click_link "Close Registration"

    expect(page).to have_content("Tournament has been updated")
    expect(page).to have_link("Open Registration")
    expect(page).not_to have_button("Add Player")
    visit '/'
    expect(page).not_to have_button("Add")
  end
end
