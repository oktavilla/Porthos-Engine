require_relative '../../test_helper'
class RulesTest < ActiveSupport::TestCase
  setup do
    Porthos::Routing.rules.reset!
    Porthos::Routing.rules.draw do
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
    end
  end

  context 'recognize' do
    should 'find all matching without namespace' do
      recognized_routes = Porthos::Routing.recognize('/my-id-123')
      assert_equal 2, recognized_routes.size
    end

    should 'find all matching by namespace' do
      recognized_routes = Porthos::Routing.recognize('/my-id-123', namespace: 'posts')
      assert_equal 1, recognized_routes.size
      assert_equal 'posts', recognized_routes[0][:controller]
      assert_equal 'show', recognized_routes[0][:action]

      recognized_routes = Porthos::Routing.recognize('/my-id-123', namespace: 'authors')
      assert_equal 1, recognized_routes.size
      assert_equal 'authors', recognized_routes[0][:controller]
      assert_equal 'show', recognized_routes[0][:action]
    end

    should 'find by matching prefix' do
      recognized_routes = Porthos::Routing.recognize('/lulz/my-id-123', namespace: 'internets')
      assert_equal 1, recognized_routes.size
      assert_equal 'lols', recognized_routes[0][:controller]
      assert_equal 'show', recognized_routes[0][:action]
    end
  end
end
