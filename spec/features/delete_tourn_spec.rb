require "rails_helper"

RSpec.feature "Delete a Tournament" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date_played: "9/5/2018", closed: true)
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

  scenario "A user(admin) deletes a tournament" do
    visit "/"
    click_link("delete")

    expect(page).to have_content("Tournament has been deleted")
    expect(current_path).to eq(tournaments_path)
  end

  scenario "A user tries to delete a tournament that is not closed" do
    @tournament.update( {closed: false})
    visit "/"

    expect(page).not_to have_link("delete")
    expect(page).to have_content(@tournament.name)
    expect(page).to have_content(@tournament.date_played)
  end

  # scenario "A non-admin user tries to delete a tournament" do
  #   visit '/'
  #   click_link 'Log out'
  #
  #   visit '/tournaments/#{@tournament.id}/destroy'
  #   expect(page).to have_content("You do not have access to that page")
  #   expect(current_path).to eq(root_path)
  # end
end
