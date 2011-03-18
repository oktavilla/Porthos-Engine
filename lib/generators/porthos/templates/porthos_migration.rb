class PorthosMigration < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string   "url"
      t.integer  "status", :default => 0
      t.string   "controller"
      t.string   "action"
      t.string   "resource_type"
      t.integer  "resource_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "restricted", :default => false
    end

    add_index "nodes", ["slug"], :name => "index_nodes_on_slug"
    add_index "nodes", ["controller", "action", "resource_id", "resource_type"], :name => "index_nodes_on_controller_and_action_and_resource"
    add_index "nodes", ["resource_type", "resource_id"], :name => "index_nodes_on_resource_type_and_resource_id"
  end

  def self.down
    drop_table :nodes
  end
end