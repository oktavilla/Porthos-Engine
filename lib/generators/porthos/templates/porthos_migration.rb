class CreatePorthosTables < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string   "url"
      t.integer  "status", :default => 0
      t.string   "controller"
      t.string   "action"
      t.string   "resource_type"
      t.integer  "resource_id"
      t.integer  "field_set_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "restricted", :default => false
    end

    add_index "nodes", ["url"], :name => "index_nodes_on_url"
    add_index "nodes", ["field_set_id"], :name => "index_nodes_on_field_set_id"
    add_index "nodes", ["resource_id", "resource_type"], :name => "index_nodes_on_resource_id_and_resource_type"

    create_table "content_images", :force => true do |t|
      t.integer  "image_asset_id"
      t.string   "title"
      t.text     "caption"
      t.string   "copyright"
      t.string   "style"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "downloadable",   :default => false
    end

    add_index "content_images", ["image_asset_id"], :name => "index_content_images_on_image_asset_id"

    create_table "content_lists", :force => true do |t|
      t.string   "name"
      t.string   "handle"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "content_lists", ["handle"], :name => "index_content_lists_on_handle"

    create_table "contents", :force => true do |t|
      t.integer  "context_id"
      t.integer  "column_position"
      t.integer  "position"
      t.integer  "resource_id"
      t.string   "resource_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id"
      t.string   "type"
      t.string   "accepting_content_resource_type"
      t.boolean  "active",                          :default => true, :null => false
      t.string   "context_type"
      t.integer  "restrictions_count"
    end

    add_index "contents", ["context_id", "context_type", "position"], :name => "index_contents_on_context_id_and_context_type_and_position"
    add_index "contents", ["parent_id"], :name => "index_contents_on_parent_id"

    create_table "content_modules", :force => true do |t|
      t.string   "name"
      t.string   "template"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "custom_associations", :force => true do |t|
      t.integer  "context_id"
      t.string   "context_type"
      t.integer  "target_id"
      t.string   "target_type"
      t.string   "relationship"
      t.integer  "field_id"
      t.string   "handle"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "custom_associations", ["context_id", "context_type"], :name => "index_custom_associations_on_context_id_and_context_type"
    add_index "custom_associations", ["field_id"], :name => "index_custom_associations_on_field_id"
    add_index "custom_associations", ["handle"], :name => "index_custom_associations_on_handle"
    add_index "custom_associations", ["target_id", "target_type"], :name => "index_custom_associations_on_target_id_and_target_type"

    create_table "custom_attributes", :force => true do |t|
      t.string   "type"
      t.integer  "context_id"
      t.string   "context_type"
      t.integer  "field_id"
      t.string   "handle"
      t.string   "string_value"
      t.text     "text_value"
      t.datetime "date_time_value"
      t.boolean  "boolean_value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "custom_attributes", ["context_id", "context_type"], :name => "index_custom_attributes_on_context_id_and_context_type"
    add_index "custom_attributes", ["field_id"], :name => "index_custom_attributes_on_field_id"
    add_index "custom_attributes", ["handle"], :name => "index_custom_attributes_on_handle"

    create_table "field_sets", :force => true do |t|
      t.integer  "position"
      t.string   "title"
      t.string   "page_label"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "handle"
      t.string   "template_name"
      t.boolean  "pages_sortable"
      t.boolean  "allow_categories", :default => false
      t.boolean  "allow_node_placements", :default => false
    end

    add_index "field_sets", ["handle"], :name => "index_field_sets_on_handle"

    create_table "fields", :force => true do |t|
      t.string   "type"
      t.integer  "field_set_id"
      t.string   "label"
      t.string   "handle"
      t.string   "target_handle"
      t.integer  "position"
      t.boolean  "required",              :default => false
      t.text     "instructions"
      t.boolean  "allow_rich_text",       :default => false
      t.integer  "association_source_id"
      t.string   "relationship"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "fields", ["field_set_id"], :name => "index_fields_on_field_set_id"
    add_index "fields", ["handle"], :name => "index_fields_on_handle"
    add_index "fields", ["target_handle"], :name => "index_fields_on_target_handle"
    add_index "fields", ["association_source_id"], :name => "index_fields_on_association_source_id"


    create_table "pages", :force => true do |t|
      t.integer  "field_set_id"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.string   "slug"
      t.string   "title"
      t.string   "layout_class"
      t.integer  "column_count"
      t.integer  "position"
      t.boolean  "active",                  :default => true
      t.boolean  "restricted",              :default => false
      t.datetime "published_on"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "pages", ["field_set_id"], :name => "index_pages_on_field_set_id"
    add_index "pages", ["slug"], :name => "index_pages_on_slug"

    create_table "content_textfields", :force => true do |t|
      t.string   "filter"
      t.string   "class_name"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
    end

    create_table "roles", :force => true do |t|
      t.string "name"
    end

    add_index "roles", ["name"], :name => "index_roles_on_name"
    create_table "user_roles", :force => true do |t|
      t.integer  "user_id"
      t.integer  "role_id"
      t.datetime "created_at"
    end

    add_index "user_roles", ["role_id"], :name => "index_user_roles_on_role_id"
    add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

    create_table "users", :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.string   "login"
      t.string   "email"
      t.string   "phone"
      t.string   "cell_phone"
      t.string   "crypted_password",          :limit => 40
      t.string   "salt",                      :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token"
      t.datetime "remember_token_expires_at"
      t.integer  "avatar_id"
    end

    add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"

    create_table "delayed_jobs", :force => true do |t|
      t.integer  "priority",   :default => 0
      t.integer  "attempts",   :default => 0
      t.text     "handler"
      t.string   "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

    create_table "taggings", :force => true do |t|
      t.integer "tag_id"
      t.integer "taggable_id"
      t.string  "taggable_type"
      t.string  "namespace"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

    create_table "tags", :force => true do |t|
      t.string "name"
    end

    add_index "tags", ["name"], :name => "index_tags_on_name"

    create_table "comments", :force => true do |t|
      t.integer  "commentable_id"
      t.string   "commentable_type"
      t.string   "name"
      t.string   "email"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ip_address"
      t.string   "url"
      t.boolean  "spam",             :default => false
      t.float    "spaminess"
      t.string   "signature"
    end

    add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"

    create_table 'site_settings', :force => true do |t|
      t.string 'name'
      t.string 'value'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
    add_index :site_settings, :name, :name => 'site_settings_name'

    create_table "redirects", :force => true do |t|
      t.string   "path"
      t.string   "target"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "redirects", ["path"], :name => "index_redirects_on_path"

    # Create default admin user

    admin_role = Role.create(:name => 'Admin')
    public_role = Role.create(:name => 'Public')
    site_admin_role = Role.create(:name => 'SiteAdmin')
    admin_user = User.create(:login => 'admin', :password => 'password', :password_confirmation => 'password', :first_name => 'Admin', :last_name => 'Admin', :email => 'admin@example.com')
    UserRole.create(:role_id => admin_role.id, :user_id => admin_user.id)
    UserRole.create(:role_id => site_admin_role.id, :user_id => admin_user.id)
  end

  def self.down
    drop_table :nodes
  end
end
