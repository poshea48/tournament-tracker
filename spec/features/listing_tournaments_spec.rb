require "rails_helper"

RSpec.feature "Listing Tournaments" do
  before do
    @tourn1 = Tournament.create(name: "Tournament One", date: "9/3/18", tournament_type: 'kob')
    @tourn2 = Tournament.create(name: "Tournament Two", date: "9/4/18", tournament_type: 'team')

  end
  scenario "user lists all tournaments" do
    visit "/"

    expect(page).to have_content(@tourn1.name)
    expect(page).to have_content(@tourn1.date)
    expect(page).to have_content(@tourn1.tournament_type.upcase)

    expect(page).to have_content(@tourn2.name)
    expect(page).to have_content(@tourn2.date)
    expect(page).to have_content(@tourn2.tournament_type.capitalize)


    expect(page).to have_link(@tourn1.name)
    expect(page).to have_link(@tourn2.name)
    expect(page).to have_button("Join Tournament"), count: 2
  end

  scenario "there are no tournaments" do
    Tournament.delete_all
    visit "/"

    expect(page).not_to have_content(@tourn1.name)
    expect(page).not_to have_content(@tourn1.date)
    expect(page).not_to have_content(@tourn1.tournament_type.upcase)

    expect(page).not_to have_content(@tourn2.name)
    expect(page).not_to have_content(@tourn2.date)
    expect(page).not_to have_content(@tourn2.tournament_type.capitalize)

    expect(page).not_to have_link(@tourn1.name)
    expect(page).not_to have_link(@tourn2.name)

    within("td[colspan='4']") do
      expect(page).to have_content("No Tournaments")
    end
  end
end
