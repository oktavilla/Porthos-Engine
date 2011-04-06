# Seeds for Porthos
# $ rails runner db/porthos_seeds.rb
#
# Create default admin user

admin_role = Role.create(:name => 'Admin')
public_role = Role.create(:name => 'Public')
site_admin_role = Role.create(:name => 'SiteAdmin')
admin_user = User.create(:login => 'admin', :password => 'password', :password_confirmation => 'password', :first_name => 'Admin', :last_name => 'Admin', :email => 'admin@example.com')
UserRole.create(:role_id => admin_role.id, :user_id => admin_user.id)
UserRole.create(:role_id => site_admin_role.id, :user_id => admin_user.id)

# Create default field set

FieldSet.create(:title => 'Article', :page_label => 'Title', :handle => 'article', :template_name => 'blog', :allow_node_placements => true)

# Create root node

Node.create({
  :name => 'Start',
  :status => 1,
  :controller => 'pages',
  :action => 'index',
  :field_set => FieldSet.first
})
