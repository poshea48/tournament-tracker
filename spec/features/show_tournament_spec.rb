require "rails_helper"

RSpec.feature "Show Tournament" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')
  end

  scenario "user shows individual tournament" do
    visit "/"
    click_link @tournament.name

    expect(page).to have_content(@tournament.name)
    expect(page).to have_content(@tournament.date)
    expect(page).to have_content(@tournament.tournament_type.upcase)

    expect(current_path).to eq(tournament_path(@tournament))

    expect(page).to have_content("Players")
    expect(page).to have_link("Pool Play")
    expect(page).to have_link("Playoffs")
  end
end
