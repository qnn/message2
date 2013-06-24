require 'spec_helper'

describe "messages/edit" do
  before(:each) do
    @message = assign(:message, stub_model(Message,
      :name => "MyString",
      :gender => 1,
      :phone_number => "MyString",
      :qq_number => 1,
      :title => "MyString",
      :content => "MyText"
    ))
  end

  it "renders the edit message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", message_path(@message), "post" do
      assert_select "input#message_name[name=?]", "message[name]"
      assert_select "select#message_gender[name=?]", "message[gender]"
      assert_select "input#message_phone_number[name=?]", "message[phone_number]"
      assert_select "input#message_qq_number[name=?]", "message[qq_number]"
      assert_select "input#message_title[name=?]", "message[title]"
      assert_select "textarea#message_content[name=?]", "message[content]"
    end
  end
end
