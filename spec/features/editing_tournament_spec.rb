require "rails_helper"

RSpec.feature "Edit Tournament" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date_played: "9/5/2018")
  end

  scenario "A user updates a tournament" do
    visit "/"
    click_link @tournament.name
    click_link "Edit"

    fill_in "Name", with: "Updated Tournament One"
    fill_in "Date played", with: "9/8/2018"
    click_button "Update Tournament"

    expect(page).to have_content "Tournament has been updated"
    expect(page.current_path).to eq(tournament_path(@tournament))
  end

  scenario "A user fails to update successfully" do
    visit "/"
    click_link @tournament.name
    click_link "Edit"

    fill_in "Name", with: ""
    fill_in "Date played", with: "9/8/2018"
    click_button "Update Tournament"

    expect(page).to have_content "Tournament has not been updated"
    expect(page.current_path).to eq(tournament_path(@tournament))
  end
end
