require "rails_helper"

RSpec.feature "Delete a Tournament" do
  before do
    @tournament = Tournament.create(name: "Tournament One", date_played: "9/5/2018", closed: true)
  end

  scenario "A user(admin) deletes a tournament" do
    visit "/"
    click_link("delete")

    expect(page).to have_content("Tournament has been deleted")
    expect(current_path).to eq(tournaments_path)
  end

  scenario "A user tries to delete a tournament that is not closed" do
    @tournament.update( {closed: false})
    visit "/"

    expect(page).not_to have_link("delete")
    expect(page).to have_content(@tournament.name)
    expect(page).to have_content(@tournament.date_played)
  end
end
