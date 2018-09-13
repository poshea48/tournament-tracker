require "rails_helper"

RSpec.feature "Log Users out" do
  before do
    @user = User.create({ first_name: "User", last_name: "One",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password' })
    visit '/'
    click_link "Log in"
    fill_in "Email", with: @user.email
    fill_in "Password", with: 'password'
    click_button "Log in"

  end

  scenario "successfully" do
    visit '/'
    click_link 'Log out'

    expect(page).to have_content("You have logged out successfully")
    expect(page).not_to have_link("Log out")
    expect(current_path).to eq(tournaments_path)
  end

  scenario "must be logged in to log out" do
    visit '/'
    click_link "Log out"
    visit '/logout'
    expect(current_path).to eq(tournaments_path)
  end
end
