require_relative '../test_helper'
class UrlResolverTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rails.application.routes.url_helpers if defined?(Rails)

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

  context 'When generating urls for models with a connected node' do
    setup do
      Factory.define :test_post do |f|
      end
      
      @test_post = Factory(:test_post)
      @node = Factory(:node, {
        :url => '/a-url-to-a-post',
        :controller => 'test_posts',
        :action => 'show',
        :resource_type => 'TestPost',
        :resource_id => @test_post.id
      })
    end

    should 'rewrite the path to match the nodes url' do
      assert_equal @node.url, test_post_path(@test_post)
    end
  end

  context "When getting a custom url" do

    context 'for an index action' do
      setup do
        @node = Factory(:node, :controller => 'test_posts', :action => 'index')
      end

      should 'have a /test_posts route' do
        get '/test_posts'
        assert_equal 200, response.status.to_i
      end

      should 'rewrite params to match the node' do
        get @node.url
        assert_equal "test_posts", params[:controller]
        assert_equal "index", params[:action]
      end
    end

    context 'with custom parameters' do
      setup do
        @node = Factory(:node, :url => '/blog', :controller => 'test_posts', :action => 'index')
        Porthos::Routing.rules += [
          {
            :test => /(^.*)\/(\d{4})\-(\d{2})\-(\d{2})/,
            :matches => ['url', 'year', 'month', 'day']
          }
        ]
      end

      should 'recognize the params' do
        get "#{@node.url}/2011-01-02"
        assert_equal "test_posts", params[:controller]
        assert_equal "index", params[:action]
        assert_equal '2011', params[:year]
        assert_equal '01', params[:month]
        assert_equal '02', params[:day]
      end
    end

    context 'for a resource' do
      setup do
        @node = Factory(:node, {
          :controller => 'test_posts',
          :action => 'show',
          :resource_type => 'TestPost',
          :resource_id => 1
        })
      end

      should 'have a /test_posts/1 route' do
        get '/test_posts/1'
        assert_equal 200, response.status.to_i
      end

      should 'rewrite params to match the node' do
        get @node.url
        assert_equal "test_posts", params[:controller]
        assert_equal "show", params[:action]
        assert_equal 1, params[:id].to_i
      end
    end
  end
end