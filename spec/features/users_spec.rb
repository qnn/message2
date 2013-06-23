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

  scenario "admin can create, edit and delete message" do
    create_new_message
    expect(page).to have_content "Message was successfully created."

    message = Message.last
    visit edit_message_path(message)
    fill_in "Name", :with => "Sheldon Cooper"
    select "Mr.", :from => "message_gender"
    fill_in "Phone number", :with => "0987654321"
    fill_in "Title", :with => "I'm testing if I can edit this message."
    fill_in "Content", :with => "Lorem ipsum dolor sit amet, \
      consectetur adipisicing elit, sed do eiusmod tempor \
      incididunt ut labore et dolore magna aliqua."
    click_button "Update Message"
    expect(page).to have_content "Message was successfully updated."

    visit messages_path
    click_link "Destroy"
    expect(page).to have_content "Message was successfully deleted."
  end

  scenario "admin can see list of users" do
    visit users_path
    expect(page).to have_content "Listing users"
  end

  scenario "admin can create, read, update and delete user" do
    username = "CommanderShepard"
    email = "shepard@normandy.com"
    password = "shepard123"
    visit new_user_path
    select "User", :from => "Role"
    fill_in "Username", :with => username
    fill_in "Email", :with => email
    fill_in "Password", :with => password
    click_button "Create User"
    expect(page).to have_content "User was successfully created."

    expect(page).to have_content email
    expect(page).to have_content username

    username.reverse!
    click_link "Edit"
    select "Moderator", :from => "Role"
    fill_in "Username", :with => username.reverse
    click_button "Update User"
    expect(page).to have_content "User was successfully updated."

    click_link "Delete"
    expect(page).to have_content "User was successfully deleted."
  end
end
