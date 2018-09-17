require 'rails_helper'

RSpec.feature "Creating Tournaments" do
  before do
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

  scenario "An admin user creates a KOB tournament" do
    visit "/"
    click_link "Create New Tournament"
    fill_in "Name", with: "Test Tournament"
    fill_in "Date", with: "September 3, 2018"
    choose("KOB")
    click_button "Create Tournament"

    expect(page).to have_content("Tournament has been created")
    expect(page.current_path).to eq(tournaments_path)
  end

  scenario "An admin user creates a Team play tournament" do
    visit "/"
    click_link "Create New Tournament"
    fill_in "Name", with: "Test Tournament"
    fill_in "Date", with: "September 3, 2018"
    choose("Team")
    click_button "Create Tournament"

    expect(page).to have_content("Tournament has been created")
    expect(page.current_path).to eq(tournaments_path)
  end

  scenario "An admin user fails to create a new tournament" do
    visit "/"
    click_link "Create New Tournament"
    fill_in "Name", with: ""
    fill_in "Date", with: ""
    click_button "Create Tournament"

    expect(page).to have_content("Tournament has not been created")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Date can't be blank")
  end

  scenario "Non-admin user tries to create a tournament" do
    visit '/'
    click_link "Log out"

    visit '/'
    click_link "Log in"
    fill_in "Email", with: @non_admin.email
    fill_in "Password", with: 'password'
    click_button "Log in"

    visit '/'
    expect(page).not_to have_link "Create New Tournament"

    visit '/tournaments/new'
    expect(page).to have_content("You do not have access to that page")
    expect(current_path).to eq(root_path)
  end
end
