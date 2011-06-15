# Define a bare test case to use with Capybara
class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  Rails.application.routes.default_url_options[:host]= 'example.com'
  include Rails.application.routes.url_helpers
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

protected

  def has_flash_message?(copy)
    page.find(".flash.notice").has_content?(copy)
  end

  def login!
    @user = Factory.create(:user, {
      :username => 'a-user',
      :password => 'password',
      :password_confirmation => 'password'
    })
    visit admin_login_path

    fill_in User.human_attribute_name('username'), :with => 'a-user'
    fill_in User.human_attribute_name('password'), :with => 'password'

    click_button I18n.t(:'admin.sessions.new.login')
  end
end
