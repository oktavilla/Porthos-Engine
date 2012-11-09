require_relative '../../test_helper'
require 'minitest/autorun'

describe AssetAssociation do
  include WebMock::API
  include PorthosAssetTestHelpers

  before :each do
    DatabaseCleaner.start
    stub_resizor_post
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe "with an associated image" do
    let :collection do
      DatumCollection.new
    end

    let :image do
      FactoryGirl.create :image_asset, file: new_tempfile('image')
    end

    subject do
      AssetAssociation.new asset: image
    end

    it "delegates css_class to the display_option" do
      subject.display_option = DisplayOption.new css_class: "test-me"

      subject.css_class.must_equal "test-me"
    end

    describe "as a direct child to a datum collection" do
      it "has a selection of display options" do
        collection.data << subject

        display_option = stub
        image_display_options = stub

        image_display_options.expects(:ordered).returns [display_option]
        DisplayOption.expects(:by_group).with('image').returns image_display_options

        subject.display_options.must_equal [display_option]
      end
    end

    describe "#url" do
      before :each do
      end

      it "fallsback to the fallback size" do
        subject.url(size: nil, default_size: "100x20").must_equal subject.asset.url(size: "100x20")
        subject.url(default_size: "100x20").must_equal subject.asset.url(size: "100x20")
      end

      it "is contructed using the display option" do
        subject.display_option = DisplayOption.new format: '100x123'

        subject.url(default_size: "50x50", size: nil).must_equal subject.asset.url(size: "100x123")
        subject.url(default_size: "50x50").must_equal subject.asset.url(size: "100x123")
      end

      it "overrides display options" do
        subject.display_option = DisplayOption.new format: '100x123'

        subject.url(size: "100", default_size: "50").must_equal subject.asset.url(size: "100")
      end
    end

    describe "as part of another datum" do
      it "has no display options" do
        DisplayOption.expects(:by_group).never
        subject.display_options.must_equal []
      end
    end
  end
end
