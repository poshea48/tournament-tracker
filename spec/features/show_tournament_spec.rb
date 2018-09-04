require "rails_helper"

RSpec.feature "Show Tournament" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date_played: "9/5/2018")
  end

  scenario "user shows individual tournament" do
    visit "/"
    click_link @tournament.name

    expect(page).to have_content(@tournament.name)
    expect(page).to have_content(@tournament.date_played)
    expect(current_path).to eq(tournament_path(@tournament))

    expect(page).to have_content("Teams")
    expect(page).to have_link("Pool Play")
    expect(page).to have_link("Playoffs")
  end
end
