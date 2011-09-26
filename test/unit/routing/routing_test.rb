require_relative '../../test_helper'
class RulesTest < ActiveSupport::TestCase
  setup do
    Porthos::Routing::Recognize.rules.reset!
    Porthos::Routing::Recognize.rules.draw do
      match ':id',
        to: { controller: 'authors', action: 'show'},
        constraints: { id: '([a-z0-9\-\_]+)' },
        namespace: 'authors'
      match ':id',
        to: { controller: 'posts', action: 'show' },
        constraints: { id: '([a-z0-9\-\_]+)' },
        namespace: 'posts'
      match ':id',
        to: { controller: 'lols', action: 'show' },
        constraints: { id: '([a-z0-9\-\_]+)' },
        namespace: 'internets',
        prefix: 'lulz'
      match 'cheers-dude',
        to: { controller: 'lols', action: 'thanks' },
        namespace: 'internets'
    end
  end

  context 'recognize' do
    should 'find all matching without namespace' do
      recognized_routes = Porthos::Routing::Recognize.run('/my-id-123')
      assert_equal 2, recognized_routes.size
    end

    should 'find all matching by namespace' do
      recognized_routes = Porthos::Routing::Recognize.run('/my-id-123', namespace: 'posts')
      assert_equal 1, recognized_routes.size
      recognized_routes[0].tap do |route|
        assert_equal 'posts', route[:controller]
        assert_equal 'show', route[:action]
        assert_equal 'my-id-123', route[:id]
      end

      recognized_routes = Porthos::Routing::Recognize.run('/my-id-123', namespace: 'authors')
      assert_equal 1, recognized_routes.size
      recognized_routes[0].tap do |route|
        assert_equal 'authors', route[:controller]
        assert_equal 'show', route[:action]
        assert_equal 'my-id-123', route[:id]
      end
    end

    should 'find by matching prefix' do
      recognized_routes = Porthos::Routing::Recognize.run('/lulz/my-id-123', namespace: 'internets')
      assert_equal 1, recognized_routes.size
      recognized_routes[0].tap do |route|
        assert_equal 'lols', route[:controller]
        assert_equal 'show', route[:action]
        assert_equal 'my-id-123', route[:id]
      end
    end

    should 'allow a prefixed route to be mounted at any point in the url' do
      recognized_lol = Porthos::Routing::Recognize.run('/lulz/my-id-123', namespace: 'internets').first
      assert_equal 'lols', recognized_lol[:controller]
      assert_equal 'show', recognized_lol[:action]
      assert_equal 'my-id-123', recognized_lol[:id]
      recognized_omg = Porthos::Routing::Recognize.run('/omg-lol/lulz/my-id-123', namespace: 'internets').first
      assert_equal 'lols', recognized_omg[:controller]
      assert_equal 'show', recognized_omg[:action]
      assert_equal 'my-id-123', recognized_omg[:id]
    end

    should 'not look further then the defined path' do
      recognized_routes = Porthos::Routing::Recognize.run('/cheers-dude', namespace: 'internets')
      assert_equal 1, recognized_routes.size
      recognized_routes[0].tap do |route|
        assert_equal 'lols', route[:controller]
        assert_equal 'thanks', route[:action]
      end
      recognized_routes = Porthos::Routing::Recognize.run('/cheers-duderinos', namespace: 'internets')
      assert_equal 0, recognized_routes.size
    end

    should 'ignore trailing slash' do
      assert_equal Porthos::Routing::Recognize.run('/cheers-dude', namespace: 'internets'), Porthos::Routing::Recognize.run('/cheers-dude/', namespace: 'internets')
    end

    should 'ignore format' do
      assert_equal Porthos::Routing::Recognize.run('/cheers-dude', namespace: 'internets'), Porthos::Routing::Recognize.run('/cheers-dude.html', namespace: 'internets')
    end
    
    should 'be case insensitive' do
      assert_equal Porthos::Routing::Recognize.run('/cheers-dude', namespace: 'internets'), Porthos::Routing::Recognize.run('/CHEERS-dude', namespace: 'internets')
    end
  end
end
