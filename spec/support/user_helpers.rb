module UserHelpers
  def it_should_not_have_access_to_crud_user(user)
    visit users_path
    page.status_code.should == 404

    page.driver.submit :post, users_path, {}
    page.status_code.should == 404

    visit new_user_path
    page.status_code.should == 404

    visit edit_user_path(user)
    page.status_code.should == 404

    visit user_path(user)
    page.status_code.should == 404

    page.driver.submit :put, user_path(user), {}
    page.status_code.should == 404

    page.driver.submit :delete, user_path(user), {}
    page.status_code.should == 404
  end
end

RSpec.configure do |config|
  config.include UserHelpers, type: :feature
end
