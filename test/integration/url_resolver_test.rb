require_relative '../test_helper'
class UrlResolverTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Dummy::Application
  end

  def url_helpers
    @url_helpers ||= Class.class_eval do
      include Dummy::Application.routes.url_helpers
    end.new
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

  context 'Porthos urls' do
    setup do
      Porthos::Routing.rules = [
        {
          :test => /(^.*)\/(\d{4})\-(\d{2})\-(\d{2})/,
          :matches => ['url', 'year', 'month', 'day'],
          :scope => 'test_posts'
        }
      ]
    end


    context 'when generated for models with a connected node' do

      context 'for a path with parameters' do
        setup do
          @node = Factory(:test_blog_node)
        end

        should 'result in a url with the parameters in the correct places' do
          assert_equal "#{@node.url}/2001-01-01", url_helpers.test_posts_path(:year => '2001', :month => '01', :day => '01')
        end
      end

      context 'with a specific resource' do
        setup do
          @test_post = Factory(:test_post)
          @node = Factory(:test_blog_post_node, :resource_id => @test_post.id)
        end

        should 'rewrite the path to match the nodes url' do
          assert_equal @node.url, url_helpers.test_post_path(@test_post)
        end
      end
    end

    context "when resolved" do

      context 'for an index action' do
        setup do
          @node = Factory(:test_blog_node)
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
          @test_post = Factory(:test_post)
          @node = Factory(:test_blog_post_node, :resource_id => @test_post.id)
        end

        should 'have a rest route route' do
          get "/test_posts/#{@test_post.id}"
          assert_equal 200, response.status.to_i
        end

        should 'rewrite params to match the node' do
          get @node.url
          assert_equal "test_posts", params[:controller]
          assert_equal "show", params[:action]
          assert_equal @test_post.id, params[:id].to_i
        end
      end
    end
  end
end