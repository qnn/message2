require 'spec_helper'

feature "Admin has all priviledges" do
  before :each do
    password = "123456"
    User.create([{ email: "test@example.com", password: password, username: "admin", role:"admin" }])
    @admin = User.where("username = ?", "admin").first
    visit new_user_session_path
    fill_in "Login", :with => @admin.username
    fill_in "Password", :with => password
    click_button "Sign in"
  end

  scenario "admin can see list of messages" do
    visit messages_path
    expect(page).to have_content "Listing messages"
  end
end
