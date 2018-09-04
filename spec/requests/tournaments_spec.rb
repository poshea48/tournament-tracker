require "rails_helper"

RSpec.describe "Tournaments", type: :request do
  before do
    @tournament = Tournament.create(name: "Tournament One", date_played: "9/5/2018")
  end

  describe 'GET /tournaments/:id' do
    context 'with existing tournament' do
      before { get "/tournaments/#{@tournament.id}"}

      it "handles existing tournament" do
        expect(response.status).to eq 200
      end
    end

    context 'with non-existing tournament' do
      before { get '/tournaments/xxxx' }

      it "handles non-existing tournament" do
        expect(response.status).to eq 302
        flash_message = "The tournament you are looking for could not be found"
        expect(flash[:danger]).to eq flash_message
      end
    end
  end
end
