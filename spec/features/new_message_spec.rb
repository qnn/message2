require 'spec_helper'

feature "New message" do
  scenario "Someone creates a new message" do
    create_new_message
    expect(page).to have_content "Message was successfully created."
  end
end
