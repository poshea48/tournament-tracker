require "rails_helper"

RSpec.feature "Users sign in" do
  before do
    @user = User.create({ first_name: "User", last_name: "One",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password' })
  end

  scenario "user signs in successfully" do
    visit "/"
    click_link "Sign in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Sign in"

    expect(page).to have_content("You have signed in successfully")
    expect(page).to have_content("Signed in as #{@user.email}")
    expect(page.current_path).to eq(tournaments_path)
    expect(page).to have_link("Sign out")

    expect(page).not_to have_link("Sign in")
    expect(page).not_to have_link("Sign up")
  end

  scenario "user signs in unsuccessfully" do
    visit "/"
    click_link "Sign in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: 'password2'
    click_button "Sign in"

    expect(page).to have_content("Email/password combination was incorrect")
    expect(page.current_path).to eq(signin_path)

    expect(page).not_to have_link("Sign out")
  end
end
