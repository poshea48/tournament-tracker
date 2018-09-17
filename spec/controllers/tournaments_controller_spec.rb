require 'rails_helper'

RSpec.describe TournamentsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns redirect with non-admin" do
      get :new
      expect(response).to have_http_status(302)
    end

    it "returns http success with admin user" do
      @admin = User.create({ id: 1, first_name: "Admin", last_name: "User",
                            email: "admin@example.com", password: 'password',
                            password_confirmation: 'password',
                            admin: true })
      log_in(@admin)
      get :new
      expect(response).to have_http_status(:success)
    end

  end


  #
  # describe "GET #show" do
  #   it "returns http success" do
  #     get :show
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe "GET #edit" do
  #   it "returns http success" do
  #     get :edit
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
