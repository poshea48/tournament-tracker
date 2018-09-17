require "rails_helper"

RSpec.feature "Edit Tournament" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date_played: "9/5/2018")
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

  scenario "An admin user updates a tournament" do
    visit "/"
    click_link @tournament.name
    click_link "Edit"

    fill_in "Name", with: "Updated Tournament One"
    fill_in "Date played", with: "9/8/2018"
    click_button "Update Tournament"

    expect(page).to have_content "Tournament has been updated"
    expect(page.current_path).to eq(tournament_path(@tournament))
  end

  scenario "An admin user fails to update successfully" do
    visit "/"
    click_link @tournament.name
    click_link "Edit"

    fill_in "Name", with: ""
    fill_in "Date played", with: "9/8/2018"
    click_button "Update Tournament"

    expect(page).to have_content "Tournament has not been updated"
    expect(page.current_path).to eq(tournament_path(@tournament))
  end

  scenario "A non-admin user tries to edit a tournament" do
    visit '/'
    click_link 'Log out'

    click_link @tournament.name
    expect(page).not_to have_link("Edit")
    visit "/tournaments/#{@tournament.id}/edit"
    expect(page).to have_content("You do not have access to that page")
    expect(current_path).to eq root_path
  end
end
