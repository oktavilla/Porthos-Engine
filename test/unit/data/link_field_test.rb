require_relative '../../test_helper'
require 'minitest/autorun'

describe LinkField do
  it "has a target if url is specified" do
    link = LinkField.new url: 'http://example.com'
    link.has_target?.must_equal true
  end

  it "has a target if url is specified" do
    link = LinkField.new resource_id: BSON::ObjectId.new
    link.has_target?.must_equal true
  end

  it "does not have a target" do
    LinkField.new.has_target?.must_equal false
  end
end
