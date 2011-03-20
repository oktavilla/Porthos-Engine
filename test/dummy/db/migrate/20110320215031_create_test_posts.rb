class CreateTestPosts < ActiveRecord::Migration
  def self.up
    create_table :test_posts do |t|
    end
  end

  def self.down
    drop_table :test_posts
  end
end
