require "rails_helper"

RSpec.feature "Listing Tournaments" do
  before do
    @tourn1 = Tournament.create(name: "Tournament One", date_played: "9/3/18")
    @tourn2 = Tournament.create(name: "Tournament Two", date_played: "9/4/18")

  end
  scenario "user lists all tournaments" do
    visit "/"

    expect(page).to have_content(@tourn1.name)
    expect(page).to have_content(@tourn1.date_played)
    expect(page).to have_content(@tourn2.name)
    expect(page).to have_content(@tourn2.date_played)

    expect(page).to have_link(@tourn1.name)
    expect(page).to have_link(@tourn2.name)
    expect(page).to have_button("Join Tournament"), count: 2
  end

  scenario "there are no tournaments" do
    Tournament.delete_all
    visit "/"

    expect(page).not_to have_content(@tourn1.name)
    expect(page).not_to have_content(@tourn1.date_played)
    expect(page).not_to have_content(@tourn2.name)
    expect(page).not_to have_content(@tourn2.date_played)
    expect(page).not_to have_link(@tourn1.name)
    expect(page).not_to have_link(@tourn2.name)

    within("td[colspan='4']") do
      expect(page).to have_content("No Tournaments")
    end 
  end
end
