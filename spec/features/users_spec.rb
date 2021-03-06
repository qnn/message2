require 'spec_helper'

feature "Admin has all priviledges" do
  before :each do
    create_admin_then_sign_in
  end

  scenario "admin can create, edit and delete message" do
    visit messages_path
    expect(page).to have_content "Listing Messages"

    create_new_message
    expect(page).to have_content "Message was successfully created."

    message = Message.last
    visit edit_message_path(message)
    fill_in "Name", :with => "Sheldon Cooper"
    select "Mr.", :from => "message_gender"
    fill_in "Phone Number", :with => "0987654321"
    fill_in "Title", :with => "I'm testing if I can edit this message."
    fill_in "Content", :with => "Lorem ipsum dolor sit amet, \
      consectetur adipisicing elit, sed do eiusmod tempor \
      incididunt ut labore et dolore magna aliqua."
    click_button "Save Changes"
    expect(page).to have_content "Message was successfully updated."

    visit messages_path
    click_link "Delete"
    expect(page).to have_content "Message was successfully deleted."
  end

  scenario "admin can create, read, update and delete user" do
    visit users_path
    expect(page).to have_content "Listing Users"
    expect(page).to have_selector "a[href='#{users_path}']"

    username = "CommanderShepard"
    email = "shepard@normandy.com"
    password = "shepard123"
    visit new_user_path
    select "User", :from => "Role"
    fill_in "Username", :with => username
    fill_in "Email", :with => email
    fill_in "Password", :with => password
    click_button "New User"
    expect(page).to have_content "User was successfully created."

    expect(page).to have_content email
    expect(page).to have_content username

    username.reverse!
    click_link "Edit"
    select "Moderator", :from => "Role"
    fill_in "Username", :with => username.reverse
    click_button "Save Changes"
    expect(page).to have_content "User was successfully updated."

    click_link "Delete"
    expect(page).to have_content "User was successfully deleted."
  end

  scenario "admin can not delete himself/herself or admins with smaller ID" do
    click_link "Sign Out"
    username = "admin2"
    password = "123456"
    User.create([{ email: "test2@example.com", password: password, username: username, role:"admin" }])
    admin2 = User.where("username = ?", username).first
    visit new_user_session_path
    fill_in "user_login", :with => username
    fill_in "user_password", :with => password
    click_button "Sign In"

    visit user_path(admin2.id)
    click_link "Delete"
    expect(page).to have_content "You cannot delete yourself."

    visit user_path(@admin.id)
    click_link "Delete"
    expect(page).to have_content "You cannot delete admins with smaller ID than yours."
  end

  scenario "admin can not change role if there will be no admins" do
    # there is only one admin
    visit edit_user_path(@admin.id)
    select "User", :from => "Role"
    click_button "Save Changes"
    expect(page).to have_content "You can not change the role of this user. Because there will be no admins."

    # create another user
    username = "admin2"
    password = "123456"
    User.create([{ email: "test2@example.com", password: password, username: username, role:"admin" }])
    admin2 = User.where("username = ?", username).first

    # repeat previous action
    # now you can change @admin's role while there is more than one admin
    visit edit_user_path(@admin.id)
    select "User", :from => "Role"
    click_button "Save Changes"
    expect(page).to have_content "You are no longer an admin."
  end
end

feature "Moderator can create/read all messages and make message visible to specific user" do
  before :each do
    username = "moderator001"
    password = "123456"
    User.create([{ email: "moderator001@example.com", password: password, username: username, role:"moderator" }])
    @user = User.where("username = ?", username).first
    visit new_user_session_path
    fill_in "user_login", :with => username
    fill_in "user_password", :with => password
    click_button "Sign In"
  end

  scenario "Moderator wants to create, read, update or delete message" do
    create_new_message
    expect(page).to have_content "Message was successfully created."
    message = Message.last

    visit messages_path
    page.status_code.should == 200
    expect(page).to have_selector "a[href='#{message_path(message)}']"
    expect(page).to have_selector "a[href='#{edit_message_path(message)}']"
    expect(page).to_not have_selector "a[href='#{message_path(message)}'][data-method='delete']"

    visit message_path(message)
    page.status_code.should == 200
    expect(page).to have_selector "a[href='#{edit_message_path(message)}']"

    visit edit_message_path(message)
    page.status_code.should == 200
    expect(page).to have_selector "a[href='#{message_path(message)}']"
    expect(page).to_not have_selector "input#message_name"
    expect(page).to_not have_selector "input#message_phone_number"
    expect(page).to_not have_selector "input#message_qq_number"
    expect(page).to_not have_selector "input#message_title"
    expect(page).to_not have_selector "textarea#message_content"
    expect(page).to have_selector "input[name='visible_to[]']"
    click_button "Save Changes"

    page.driver.submit :delete, message_path(message), {}
    page.status_code.should == 404
  end

  scenario "Moderator wants to create, read, update or delete user" do
    visit root_path
    expect(page).to_not have_selector "a[href='#{users_path}']"
    it_should_not_have_access_to_crud_user @user
  end
end

feature "User can only create and read public/private messages" do
  before :each do
    username = "user001"
    @password = "123456"
    User.create([{ email: "user001@example.com", password: @password, username: username, role:"user" }])
    @user = User.where("username = ?", username).first
    visit new_user_session_path
    fill_in "user_login", :with => username
    fill_in "user_password", :with => @password
    click_button "Sign In"
  end

  scenario "User wants to create, read, update or delete message" do
    create_new_message
    expect(page).to have_content "Message was successfully created."
    message = Message.last

    visit messages_path
    page.status_code.should == 200
    expect(page).to have_selector "a[href='#{message_path(message)}']"
    expect(page).to_not have_selector "a[href='#{edit_message_path(message)}']"
    expect(page).to_not have_selector "a[href='#{message_path(message)}'][data-method='delete']"

    visit message_path(message)
    page.status_code.should == 200
    expect(page).to_not have_selector "a[href='#{edit_message_path(message)}']"

    visit edit_message_path(message)
    page.status_code.should == 404

    # RackTest driver
    page.driver.submit :put, message_path(message), {}
    page.status_code.should == 404

    page.driver.submit :delete, message_path(message), {}
    page.status_code.should == 404
  end

  scenario "User wants to create, read, update or delete user" do
    visit root_path
    expect(page).to_not have_selector "a[href='#{users_path}']"
    it_should_not_have_access_to_crud_user @user
  end

  scenario "User wants to change username or email" do
    visit edit_user_registration_path
    page.status_code.should == 200
    expect(page).to_not have_field "Username"
    expect(page).to_not have_field "Email"
    fill_in "Current Password", :with => @password
    click_button "Update"
    expect(page).to have_content "You have updated your account successfully."
  end
end

feature "Visitors can only create message" do
  before :each do
    create_new_message
    expect(page).to have_content "Message was successfully created."
    @message = Message.last
    User.create([{ email: "user001@example.com", password: "123456", username: "user001", role:"user" }])
    @user = User.last
  end

  scenario "Visitors want to create, read, update or delete message" do
    visit messages_path
    page.status_code.should == 404

    visit message_path(@message)
    page.status_code.should == 404

    visit edit_message_path(@message)
    page.status_code.should == 404

    # RackTest driver
    page.driver.submit :put, message_path(@message), {}
    page.status_code.should == 404

    page.driver.submit :delete, message_path(@message), {}
    page.status_code.should == 404
  end

  scenario "Visitors want to create, read, update or delete user" do
    it_should_not_have_access_to_crud_user @user
  end
end
