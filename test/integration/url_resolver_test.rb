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
      Porthos::Routing.rules.reset!
      Porthos::Routing.rules.draw do
        # Posts
        match ':id',
          :to => {
            :controller => 'posts',
            :action => 'show' },
          :constraints => {
            :id => '([a-z0-9\-\_]+)' },
          :namespace => 'blog'
        match ':year/:month/:day',
          :to => {
            :controller => 'posts' },
          :constraints => {
            :year => '(\d{4})',
            :month => '(\d{2})',
            :day => '(\d{2})' },
          :namespace => 'blog'
        match ':post_id/author/:id',
          :to => {
            :controller => 'authors',
            :action => 'show' },
          :constraints => {
            :id => '([a-z0-9\-\_]+)',
            :post_id => '([a-z0-9\-\_]+)' },
          :namespace => 'blog'
        match 'contact-us',
          :to => {
            :controller => 'posts',
            :action => 'contact' },
          :namespace => 'blog'

        # Authors
        match ':id',
          :to => {
            :controller => 'authors',
            :action => 'show' },
          :constraints => {
            :id => '([a-z0-9\-\_]+)' },
          :namespace => 'authors'
        match 'contact-us',
          :to => {
            :controller => 'authors',
            :action => 'contact' },
          :namespace => 'authors'
      end

      @blog_node = Factory(:node,
        :controller => 'posts',
        :action => 'index',
        :handle => 'blog',
        :url => 'the-blog')
      @authors_node = Factory(:node,
        :controller => 'authors',
        :action => 'index',
        :handle => 'authors',
        :url => 'the-authors')
    end


    context 'when generated' do
      context 'for a path with parameters' do

        should 'result in a url with the parameters in the correct places' do
          post = Factory(:post, :handle => 'blog')
          assert_equal "/the-blog/#{post.id}", post_path(post)
          assert_equal '/the-blog/2001/01/01', posts_path(:year => '2001',
            :month => '01',
            :day => '01',
            :host => 'test.com',
            :handle => 'blog')

          author = Factory(:author, :handle => 'authors')
          assert_equal "/the-blog/#{post.id}/author/#{author.id}",
            author_path(author, :post_id => post.id, :handle => 'blog')
          assert_equal "/the-authors/#{author.id}", author_path(author)
        end

        should 'use #uri if defined on resource' do
          post = Factory(:post, :handle => 'blog')
          post.class_eval do
            def uri
              'my-super-duper-page'
            end
          end
          assert_equal "/#{@blog_node.url}/my-super-duper-page", post_path(post)
        end
      end

      context 'for a specific resource' do
        should 'rewrite the path to match the nodes url' do
          post = Factory(:post)
          node = Factory(:node, :controller => 'posts', :action => 'show', :resource => post)
          assert_equal "/#{node.url}", post_path(:id => post)
        end
      end

      context 'for a action' do
        should 'rewrite the path to matching rule' do
          assert_equal '/the-authors/contact-us', contact_authors_path(:handle => 'authors')
          assert_equal '/the-blog/contact-us', contact_posts_path(:handle => 'blog')
        end
      end

    end

    context "when resolved" do

      context 'for an index action' do
        should 'have a /posts route' do
          visit posts_path
          assert_equal 200, response.status.to_i
        end

        should 'rewrite params to match the node' do
          visit "/the-blog"
          assert_equal "posts", params[:controller]
          assert_equal "index", params[:action]

          visit "/the-authors"
          assert_equal "authors", params[:controller]
          assert_equal "index", params[:action]
        end

        should 'recognize the params' do
          visit "/the-blog/2011/01/02"
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
          @author = Factory(:author)
        end

        should 'have a rest route route' do
          visit "/posts/#{@post.id}"
          assert_equal 200, response.status.to_i
          assert_equal "posts", params[:controller]
          assert_equal "show", params[:action]
        end

        should 'rewrite params to match the node' do
          visit "/the-blog/#{@post.id}"
          assert_equal "posts", params[:controller]
          assert_equal "show", params[:action]
          assert_equal @post.to_param, params[:id]

          visit "/the-blog/#{@post.id}/author/#{@author.id}"
          assert_equal "authors", params[:controller]
          assert_equal "show", params[:action]
          assert_equal @author.to_param, params[:id]
          assert_equal @post.to_param, params[:post_id]

          visit "/the-authors/#{@author.id}"
          assert_equal "authors", params[:controller]
          assert_equal "show", params[:action]
          assert_equal @author.to_param, params[:id]
        end
      end

      context 'for a action' do
        should 'rewrite to params to match node' do
          visit "/the-authors/contact-us"
          assert_equal 200, response.status.to_i
          assert_equal "authors", params[:controller]
          assert_equal "contact", params[:action]

          visit "/the-blog/contact-us"
          assert_equal 200, response.status.to_i
          assert_equal "posts", params[:controller]
          assert_equal "contact", params[:action]
        end
      end
    end
  end
end
