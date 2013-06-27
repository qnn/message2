require 'spec_helper'

feature "Message visibility" do
  scenario "Message can be visible to only some users" do
    password = "123456"
    create_new_message
    message = Message.last
    create_admin_then_sign_in
    User.create([{ email: "user001@example.com", password: password, username: "user001", role:"user" }])
    user001 = User.last
    User.create([{ email: "user002@example.com", password: password, username: "user002", role:"user" }])
    user002 = User.last

    checkbox = "input[type=checkbox][id=visible_to_#{user001.id}]"
    visit edit_message_path(message)
    expect(page).to have_selector checkbox
    find(checkbox).should_not be_checked
    check "visible_to_#{user001.id}"
    click_button "Save Changes"
    visit edit_message_path(message)
    find(checkbox).should be_checked

    click_link "Sign Out"
    visit new_user_session_path
    fill_in "user_login", :with => user001.username
    fill_in "user_password", :with => password
    click_button "Sign In"
    visit messages_path
    expect(page).to have_selector "a[href='#{message_path(message)}']"
    visit message_path(message)
    page.status_code.should == 200
    expect(page).to have_content "Only you" # user will not see details of visible_to

    click_link "Sign Out"
    visit new_user_session_path
    fill_in "user_login", :with => user002.username
    fill_in "user_password", :with => password
    click_button "Sign In"
    visit messages_path
    expect(page).to_not have_selector "a[href='#{message_path(message)}']"
    visit message_path(message)
    page.status_code.should == 404
  end

  scenario "Delete a message should delete all related flaggings." do
    create_new_message
    message = Message.last
    User.create([{ email: "user001@example.com", password: "123456", username: "user001", role:"user" }])
    user001 = User.last
    sql = "flag = 'visible_to' AND flaggable_type = 'Message' AND flaggable_id = #{message.id} AND flagger_type = 'User' AND flagger_id = #{user001.id}"
    Flagging.where(sql).count.should == 0

    create_admin_then_sign_in
    checkbox = "input[type=checkbox][id=visible_to_#{user001.id}]"
    visit edit_message_path(message)
    expect(page).to have_selector checkbox
    check "visible_to_#{user001.id}"
    click_button "Save Changes"
    Flagging.where(sql).count.should == 1

    visit edit_message_path(message)
    click_link "Delete"
    Flagging.where(sql).count.should == 0
  end
end
