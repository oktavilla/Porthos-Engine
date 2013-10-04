require_relative "../test_helper"
require "minitest/autorun"

describe "AssetUsages" do
  let(:item){ FactoryGirl.build :item, id: 123 }
  let(:asset){ FactoryGirl.build :asset, created_by: FactoryGirl.build(:user) }
  subject{ AssetUsages.new asset }

  it "is initialized with a asset" do
    subject.asset.must_equal asset
  end

  it "adds usages to asset" do
    usage = {
      "usage_type" => "Item",
      "usage_id" => "123",
      "container_id" => "a context",
    }
    subject.expects :save_asset

    subject.add item, "a context"

    asset._usages.must_equal [usage]
  end

  it "deletes usages from asset" do
    asset.stubs _usages: [{
      "usage_type" => "Item",
      "usage_id" => "123",
      "container_id" => "a context"
    }]
    subject.expects :save_asset

    subject.remove item, "a context"

    asset._usages.must_equal []
  end

  it "is enumerable" do
    Item.stubs(:find).with("123").returns item
    asset.stubs _usages: [{
      "usage_type" => "Item",
      "usage_id" => "123",
      "container_id" => "a context"
    }]
    usages = []
    subject.each {|using_object| usages << using_object }

    usages.must_equal [item]
  end
end
