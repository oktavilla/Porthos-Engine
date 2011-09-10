require_relative '../../test_helper'
class EmailvalidatorTest < ActiveSupport::TestCase
  setup do
    class PersonWithEmail
      include MongoMapper::Document
      key :email_address, String
      validates :email_address,
                :email => true
    end
    @person = PersonWithEmail.new(:email_address => 'bender@porthos-engine.com')
  end

  test 'is valid' do
    assert @person.valid?
  end

  test 'has error with invalid email' do
    ['invalid', 'invalid@invalid', 'invalid.com', 'invalid @address.com', 'invalid@ address.com'].each do |invalid_email_address|
      @person.email_address = 'invalid@invalid'
      refute @person.valid?, "should not be valid for: #{invalid_email_address}"
      assert_equal I18n.t(:'mongo_mapper.errors.messages.invalid_email'), @person.errors[:email_address].first
    end
  end

end