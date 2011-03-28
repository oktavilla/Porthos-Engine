require_relative '../test_helper'

class TagTest < ActiveSupport::TestCase
  context 'A Tag' do
    setup do
      @tag = Factory(:tag)
    end
    subject { @tag }

    should have_many(:taggings).dependent(:destroy)
    should have_many(:taggables).through(:taggings)

    should validate_presence_of :name
    should validate_uniqueness_of :name

    should 'lowercase the name' do
      @tag.update_attributes(:name => 'A new name   ')
      assert_equal 'a new name', @tag.name
    end

    should "know it's tagged model classes" do
      assert !@tag.tagged_models.any?
      @page = Factory(:page)
      @page.tag_names = @tag.name
      @page.save
      assert_equal [Page], @tag.reload.tagged_models
    end
  end

end