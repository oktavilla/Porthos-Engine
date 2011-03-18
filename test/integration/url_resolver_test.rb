require_relative '../test_helper'
class UrlResolverTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Dummy::Application
  end

  def params
    response.status.to_s.include?('200') ? eval(response.body).symbolize_keys : {}
  end

  def response
    last_response
  end

  def request
    last_request
  end

  context "When getting a custom url" do
    context 'for a collection' do
      setup do
        @node = Factory(:node, :controller => 'posts', :action => 'index')
      end

      should 'have a /posts route' do
        get '/posts'
        assert_equal 200, response.status.to_i
      end

      should 'rewrite params to match the node' do
        get @node.url
        assert_equal "posts", params[:controller]
        assert_equal "index", params[:action]
      end
    end

    context 'for a resource' do
      setup do
        @node = Factory(:node, {
          :controller => 'posts',
          :action => 'show',
          :resource_type => 'Post',
          :resource_id => 1
        })
      end

      should 'have a /posts/1 route' do
        get '/posts/1'
        assert_equal 200, response.status.to_i
      end

      should 'rewrite params to match the node' do
        get @node.url
        assert_equal "posts", params[:controller]
        assert_equal "show", params[:action]
        assert_equal 1, params[:id].to_i
      end
    end
  end
end