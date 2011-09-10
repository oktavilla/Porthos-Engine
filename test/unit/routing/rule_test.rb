require_relative '../../test_helper'
class RuleTest < ActiveSupport::TestCase
  include Porthos::Routing

  setup do
    @attrs = {
      path: '%{authors}/:genre/:id',
      constraints: {
        genre: '([a-z0-9\-\_\s\p{Word}]+)',
        id: '([a-z0-9\-\_]+)'
      },
      controller: 'authors',
      action: 'show',
      namespace: 'authors'
    }
    @rule = Rule.new(@attrs)
  end

  should "initialize with attributes" do
    assert_equal @attrs[:path], @rule.path
    assert_equal @attrs[:constraints], @rule.constraints
    assert_equal @attrs[:controller], @rule.controller
    assert_equal @attrs[:action], @rule.action
    assert_equal @attrs[:namespace], @rule.namespace
  end

  should 'know if it matches a certain criteria' do
    refute @rule.match?({bananas: 9}), 'should not match bananas = 9'
    assert @rule.match?({ controller: 'authors', namespace: 'authors' }), 'should match controller and namespace'
  end

  context "path" do
    should "have param keys" do
      assert_equal [:genre, :id], @rule.param_keys
    end

    should "be translated" do
      assert_equal "#{I18n.t('routes.authors')}/:genre/:id", @rule.translated_path
    end

    should 'be compiled to regexp with constraints (without prefix)' do
      constraints = @attrs[:constraints]
      assert_equal "^(.*|)/#{I18n.t('routes.authors')}/#{constraints[:genre]}/#{constraints[:id]}(/|)$", @rule.regexp_template
    end

    should 'be compiled to regexp with constraints (with prefix)' do
      constraints = @attrs[:constraints]
      @rule.prefix = 'super-items'
      assert_equal "^(/super-items)/#{I18n.t('routes.authors')}/#{constraints[:genre]}/#{constraints[:id]}(/|)$", @rule.regexp_template
    end

    should 'get computed' do
      node = Node.new(controller: 'authors', action: 'index')
      computed_path = @rule.computed_path(node, genre: 'sci-fi', id: '78-robert-a-heinlein')

      assert_equal "/#{I18n.t('routes.authors')}/sci-fi/78-robert-a-heinlein", computed_path
    end
  end
end
