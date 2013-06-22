require 'spec_helper'

feature "New message" do
  scenario "Someone creates a new message" do
    visit root_path
    fill_in "Name", :with => "Maggie Conley"
    select "Ms.", :from => "message_gender"
    fill_in "Phone number", :with => "1234567890"
    fill_in "Title", :with => "I'm testing if this app works."
    fill_in "Content", :with => "Lorem ipsum dolor sit amet, \
      consectetur adipisicing elit, sed do eiusmod tempor \
      incididunt ut labore et dolore magna aliqua."
    click_button "Create Message"
    expect(page).to have_content "Message was successfully created."
  end
end
