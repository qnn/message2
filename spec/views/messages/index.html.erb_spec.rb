require 'spec_helper'

describe "messages/index" do
  before(:each) do
    assign(:messages, [
      stub_model(Message,
        :name => "Name",
        :gender => 1,
        :phone_number => "Phone Number",
        :qq_number => 2,
        :title => "Title",
        :content => "MyText"
      ),
      stub_model(Message,
        :name => "Name",
        :gender => 1,
        :phone_number => "Phone Number",
        :qq_number => 2,
        :title => "Title",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of messages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => Message::USER_GENDER[1], :count => 2
    assert_select "tr>td", :text => "Phone Number".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
