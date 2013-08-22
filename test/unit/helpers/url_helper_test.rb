require_relative '../../test_helper'

class UrlHelperTest < ActiveSupport::TestCase
  def setup
    helper_class = Class.new { include UrlHelper }
    @helper = helper_class.new
    @helper.stubs request: request
  end

  test "#base_url" do
    assert_equal "http://site.com", @helper.base_url
  end

  test "#node_url with root node" do
    node = stub(root?: true)
    assert_equal "http://site.com", @helper.node_url(node)
  end

  test "#node_url with non-root node" do
    node = stub(root?: false, slug: "page")
    assert_equal "http://site.com/page", @helper.node_url(node)
  end

  private

  def request
    stub protocol: "http://", host: "site.com"
  end
end
