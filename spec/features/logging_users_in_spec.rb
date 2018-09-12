require "rails_helper"

RSpec.feature "Users log in" do
  before do
    @user = User.create({ first_name: "User", last_name: "One",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password' })
  end

  scenario "user logs in successfully" do
    visit "/"
    click_link "Log in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Log in"

    expect(page).to have_content("You have logged in successfully")
    expect(page).to have_content("logged in as #{@user.email}")
    expect(page.current_path).to eq(tournaments_path)
    expect(page).to have_link("Log out")

    expect(page).not_to have_link("Log in")
    expect(page).not_to have_link("Sign up")
  end

  scenario "user logs in unsuccessfully" do
    visit "/"
    click_link "Log in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: 'password2'
    click_button "Log in"

    expect(page).to have_content("Email/password combination was incorrect")
    expect(page.current_path).to eq(login_path)

    expect(page).not_to have_link("Log out")
  end
end
