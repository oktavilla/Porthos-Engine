require_relative '../test_helper'
class UrlResolverTest < ActiveSupport::IntegrationCase
  def params
    response.status.to_s.include?('200') ? eval(response.body).symbolize_keys : {}
  end

  def response
    page.driver.response
  end

  context 'Porthos urls' do

    setup do
      Porthos::Routing.rules = Porthos::Routing::Rules.new([
        :path => ":year/:month/:day",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})'
        },
        :controller => 'posts'
      ])
    end


    context 'when generated for models with a connected node' do

      context 'for a path with parameters' do
        setup do
          @node = Factory(:test_blog_node)
        end

        should 'result in a url with the parameters in the correct places' do
          assert_equal "/#{@node.url}/2001/01/01", posts_path(:year => '2001', :month => '01', :day => '01', :host => 'test.com')
        end
      end

      context 'with a specific resource' do
        setup do
          @post = Factory(:post)
          @node = Factory(:test_blog_post_node, :resource => @post)
        end

        should 'rewrite the path to match the nodes url' do
          assert_equal "/#{@node.url}", post_path(:id => @post.id, :mongo => true)
        end
      end
    end

    context "when resolved" do

      context 'for an index action' do
        setup do
          @node = Factory(:test_blog_node)
        end

        should 'have a /posts route' do
          visit '/posts'
          assert_equal 200, response.status.to_i
        end

        should 'rewrite params to match the node' do
          visit "/#{@node.url}"
          assert_equal "posts", params[:controller]
          assert_equal "index", params[:action]
        end

        should 'recognize the params' do
          visit "/#{@node.url}/2011/01/02"
          assert_equal "posts", params[:controller]
          assert_equal "index", params[:action]
          assert_equal '2011', params[:year]
          assert_equal '01', params[:month]
          assert_equal '02', params[:day]
        end

      end

      context 'for a resource' do
        setup do
          @post = Factory(:post)
          @node = Factory(:test_blog_post_node, :resource_id => @post.id)
        end

        should 'have a rest route route' do
          visit "/posts/#{@post.id}"
          assert_equal 200, response.status.to_i
        end

        should 'rewrite params to match the node' do
          visit @node.url
          assert_equal "posts", params[:controller]
          assert_equal "show", params[:action]
          assert_equal @post.id, params[:id]
        end
      end
    end
  end
end
