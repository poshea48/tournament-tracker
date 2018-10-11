require "rails_helper"

RSpec.configure do |c|
  c.include SessionsHelper
end

# RSpec.describe "an example group" do
#   it "has access to the helper methods defined in the module" do
#     expect(log_in).to be(:available)
#   end
# end

RSpec.feature "Users log in" do
  before do
    @user = User.create({ first_name: "User", last_name: "One",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password'
                        })
  end



  scenario "user logs in successfully followed by log out" do
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

    click_link "Log out"
    expect(current_path).to eq(tournaments_path)

    visit '/logout'
    expect(current_path).to eq(tournaments_path)
  end

  scenario "user checks remember me in login" do
    visit "/"
    click_link "Log in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    check "Remember me"
    expect(page).to have_field('Remember me', checked: true) # checked: false or unchecked: true for not checked
    click_button "Log in"
  end

  scenario "user logs in without cookies" do

  end

  scenario "user logs in unsuccessfully" do
    visit "/"
    click_link "Log in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: 'password2'
    click_button "Log in"

    expect(page).to have_content("Invalid Email/password combination")
    expect(page.current_path).to eq(login_path)

    expect(page).not_to have_link("Log out")
  end
end
