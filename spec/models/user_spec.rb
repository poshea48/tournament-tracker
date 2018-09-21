require 'rails_helper'
require 'pry'
RSpec.describe User, type: :model do
  it "authenticated should return false for a user with nil digest" do
    @user = User.create({ first_name: "User", last_name: "One",
                          email: "user@example.com", password: 'password',
                          password_confirmation: 'password'
                        })
    expect(@user.authenticated?('')).to eq(false)
  end

end
