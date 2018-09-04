require 'rails_helper'

RSpec.feature "Creating Tournaments" do
  scenario "A user creates a tournament" do
    visit "/"
    click_link "Create New Tournament"
    fill_in "Name", with: "Test Tournament"
    fill_in "Date", with: "September 3, 2018"
    click_button "Create Tournament"

    expect(page).to have_content("Tournament has been created")
    expect(page.current_path).to eq(tournaments_path)
  end

  scenario "A user fails to create a new tournament" do
    visit "/"
    click_link "Create New Tournament"
    fill_in "Name", with: ""
    fill_in "Date played", with: ""
    click_button "Create Tournament"

    expect(page).to have_content("Tournament has not been created")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Date played can't be blank")
  end
end
