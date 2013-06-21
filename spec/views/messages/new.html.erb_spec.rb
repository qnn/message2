require 'spec_helper'

describe "messages/new" do
  before(:each) do
    assign(:message, stub_model(Message,
      :name => "MyString",
      :gender => 1,
      :phone_number => "MyString",
      :qq_number => 1,
      :title => "MyString",
      :content => "MyText"
    ).as_new_record)
  end

  it "renders new message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", messages_path, "post" do
      assert_select "input#message_name[name=?]", "message[name]"
      assert_select "input#message_gender[name=?]", "message[gender]"
      assert_select "input#message_phone_number[name=?]", "message[phone_number]"
      assert_select "input#message_qq_number[name=?]", "message[qq_number]"
      assert_select "input#message_title[name=?]", "message[title]"
      assert_select "textarea#message_content[name=?]", "message[content]"
    end
  end
end
