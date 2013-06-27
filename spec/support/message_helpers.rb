module MessageHelpers
  def create_new_message
    visit root_path
    fill_in "Name", :with => "Maggie Conley"
    select "Ms.", :from => "message_gender"
    fill_in "Phone Number", :with => "1234567890"
    fill_in "Title", :with => "I'm testing if this app works."
    fill_in "Content", :with => "Lorem ipsum dolor sit amet, \
      consectetur adipisicing elit, sed do eiusmod tempor \
      incididunt ut labore et dolore magna aliqua."
    click_button "Submit"
  end
end

RSpec.configure do |config|
  config.include MessageHelpers, type: :feature
end
