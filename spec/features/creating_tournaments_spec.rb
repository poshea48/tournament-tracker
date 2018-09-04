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
end
