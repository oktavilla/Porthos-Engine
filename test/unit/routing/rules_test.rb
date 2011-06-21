require_relative '../../test_helper'
class RulesTest < ActiveSupport::TestCase
  include Porthos::Routing

  setup do
    @rules_attributes = [
      {
        path: '%{authors}/:genre/:id',
        constraints: {
          genre: '([a-z0-9\-\_\s\p{Word}]+)',
          id: '([a-z0-9\-\_]+)'
        },
        controller: 'authors',
        action: 'show'
      },
      {
        :path => "%{authors}/:genre/:year/:id",
        constraints:  {
          genre: '([a-z0-9\-\_\s\p{Word}]+)',
          year:  '(\d{4})',
          id: '([a-z0-9\-\_]+)'
        },
        controller:  'authors',
        action:  'show'
      },
    ]
    @rules = Rules.new(@rules_attributes)
  end

  should "initialize with array of rules as a hash and convert to Rule instances" do
    assert_equal 2, @rules.size
    assert @rules.all? { |r| r.is_a?(Rule) }
  end

  context 'adding rules' do
    setup do
      @size = @rules.size
    end

    should "work with push" do
      @rules.push [
        { path: ':id', controller:  'authors', action:   'show' },
        { path: 'by/:genre', controller:  'authors', action:  'index', constraints:  { genre: '([a-z0-9\-\_\s\p{Word}]+)' } }
      ]
      assert_equal @size + 2, @rules.size
      assert @rules.all? { |r| r.is_a?(Rule) }
    end

    should "work with append (<<)" do
      @rules << { path: ':id', controller:  'authors', action: 'show' }
      assert_equal @size + 1, @rules.size
      assert @rules.all? { |r| r.is_a?(Rule) }
    end
  end

  should "sort rules by constraints" do
    assert_equal ['%{authors}/:genre/:id', "%{authors}/:genre/:year/:id"], @rules.collect { |r| r.path }
    assert_equal ["%{authors}/:genre/:year/:id", '%{authors}/:genre/:id'], @rules.sorted.collect { |r| r.path }
  end

  should "find rules by params" do
    assert_equal @rules.first, @rules.find_matching_params({
      controller: 'authors',
      action: 'show',
      genre: 'sci-fi',
      id: '78-robert-a-heinlein'
    })
    assert_equal @rules.last, @rules.find_matching_params({
      controller: 'authors',
      action: 'show',
      genre: 'sci-fi',
      year: '1959',
      id: '78-robert-a-heinlein'
    })
  end
end