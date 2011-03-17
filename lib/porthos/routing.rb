#module Porthos
#  module Routing
#    mattr_accessor :debug
#    self.debug = false
#
#    class NodeSet
#
#      attr_accessor :add_conditions, :remove_conditions
#      attr_accessor :nodes
#      attr_reader :changed_at
#
#      def initialize
#        self.nodes = {}
#        self.add_conditions, self.remove_conditions = [], []
#        @routing   = ActionController::Routing::Routes
#      end
#
#      def load!
#        latest_caching = cache.saved_at
#        if not nodes.any? or not @@last_change or not latest_caching
#          if not cache.retrive or not cache.retrive.any?
#            Node.logger.warn("We have empty nodes, fetching from db") if Routing.debug
#            ActiveRecord::Base.connection.select_all("select id, parent_id, controller, action, resource_id, resource_class_name, slug from nodes").each do |node|
#              add node
#            end
#            update_cache
#          else
#            Node.logger.warn("We have empty nodes, fetching from cache") if Routing.debug
#            load_from_cache
#          end
#        elsif @@last_change < latest_caching
#          Node.logger.warn("Loading from cache: last_change: #{@@last_change}, cache.saved_at: #{cache.saved_at}") if Routing.debug
#          load_from_cache
#        else
#          Node.logger.warn("Nodes not changed") if Routing.debug
#          Node.logger.warn("last_change: #{@@last_change}, cache.saved_at: #{cache.saved_at}") if Routing.debug
#        end
#      end
#
#      def reload!
#        clear!
#        load!
#      end
#
#      def clear!
#        nodes.each { |id, node| remove node }
#      end
#
#      def load_from_cache
#        clear!
#        cached_nodes = cache.retrive
#        cached_nodes.each { |id, node| add node }
#        @@last_change = cache.saved_at
#      end
#
#      def update_cache
#        cache.store nodes
#        @@last_change = cache.saved_at
#        Node.logger.warn("Stored current nodes in the cache") if Routing.debug
#      end
#
#      def add(node, store_change = false)
#        route_mappings = {
#          :controller => node["controller"],
#          :action     => node["action"],
#          :id         => node["resource_id"],
#          :slug       => node["slug"]
#        }
#
#        if node['controller'] == 'pages'
#          route_mappings[:field_set_id] = node["field_set_id"]
#        end
#
#        unless node["parent_id"]
#          @routing.add_named_route('root', '', route_mappings)
#        else
#          @routing.add_named_route("node_#{node['id']}", node["slug"], route_mappings)
#          @routing.add_named_route("formatted_node_#{node['id']}", "#{node["slug"]}.:format", route_mappings)
#        end
#
#        if node['controller'] == 'pages' && node['action'] == 'index'
#          @routing.add_named_route("node_#{node['id']}_year", "#{node["slug"]}/:year", route_mappings.merge({
#            :requirements => {
#              :year => /[0-9]{4}/
#            }
#          }))
#
#          @routing.add_named_route("node_#{node['id']}_month", "#{node["slug"]}/:year/:month", route_mappings.merge({
#            :requirements => {
#              :year  => /[0-9]{4}/,
#              :month => /[0-9]{2}/
#            }
#          }))
#
#          @routing.add_named_route("node_#{node['id']}_day", "#{node["slug"]}/:year/:month/:day", route_mappings.merge({
#            :requirements => {
#              :year  => /[0-9]{4}/,
#              :month => /[0-9]{2}/,
#              :day   => /[0-9]{2}/
#            }
#          }))
#
#          route_mappings.dup.tap do |mappings|
#            mappings.delete(:id)
#            @routing.add_named_route("node_child_#{node['id']}_permalink", "#{node["slug"]}/:id", mappings.merge({
#              :action => 'show',
#              :requirements => {
#                :id => /[0-9]+\-.+/
#              }
#            }))
#
#            @routing.add_named_route("node_#{node['id']}_dated_page", "#{node["slug"]}/:year/:month/:day/:id", mappings.merge({
#              :action => 'show',
#              :requirements => {
#                :year  => /[0-9]{4}/,
#                :month => /[0-9]{2}/,
#                :day   => /[0-9]{2}/,
#                :id    => /[0-9]+\-.+/
#              }
#            }))
#
#            @routing.add_named_route("formatted_node_#{node['id']}_dated_page", "#{node["slug"]}/:year/:month/:day/:id.:format", mappings.merge({
#              :action => 'show',
#              :requirements => {
#                :year  => /[0-9]{4}/,
#                :month => /[0-9]{2}/,
#                :day   => /[0-9]{2}/,
#                :id    => /[0-9]+\-.+/
#              }
#            }))
#          end
#
#          @routing.add_named_route("search_node_#{node['id']}", "#{node["slug"]}/search.:format", route_mappings.dup.merge({
#            :action => 'search'
#          }))
#        end
#
#        add_conditions.each do |condition|
#          condition.call(node, route_mappings, @routing)
#        end
#
#        self.nodes[node["id"]] = {
#          "id"            => node["id"],
#          "parent_id"     => node["parent_id"],
#          "controller"    => node["controller"],
#          "action"        => node["action"],
#          "resource_id"   => node["resource_id"],
#          "resource_type" => node["resource_type"],
#          "slug"          => node["slug"],
#          "field_set_id"  => node["field_set_id"],
#          "resource_class_name" => node["resource_class_name"]
#        }
#        Node.logger.warn("Added route for node #{node['id']}") if Routing.debug
#        update_cache if store_change
#      end
#
#      def update(node, store_change = false)
#        Node.logger.warn("Updating route for node #{node['id']}") if Routing.debug
#        remove node
#        add node, store_change
#      end
#
#      def remove(node, store_change = false)
#        self.nodes.delete node["id"]
#        @routing.named_routes.routes.delete "node_#{node['id']}"
#        @routing.named_routes.routes.delete "formatted_node_#{node['id']}"
#        if @routing.named_routes.routes.delete "node_#{node['id']}_year"
#          @routing.named_routes.routes.delete  "node_#{node['id']}_month"
#          @routing.named_routes.routes.delete  "node_#{node['id']}_day"
#          @routing.named_routes.routes.delete  "node_#{node['id']}_dated_page"
#          @routing.named_routes.routes.delete  "formatted_node_#{node['id']}_dated_page"
#          @routing.named_routes.routes.delete  "node_child_#{node['id']}_permalink"
#        end
#
#        remove_conditions.each do |condition|
#          condition.call(node, @routing)
#        end
#
#        Node.logger.warn("Removed route for node #{node['id']}") if Routing.debug
#        update_cache if store_change
#      end
#
#      def cache
#        return @cache if @cache
#        @cache = MemCacheStore.new
#      rescue MemCache::MemCacheError => e
#        @cache = CacheFileStore.new
#      end
#
#    end
#
#    Nodes = NodeSet.new
#
#    ##
#    # Example:
#    #   c = Porthos::Routing::Cache.new(Porthos::Routing::Cache::FILE_ON_DISK)
#    #   c.set Node.find(:all, :limit => 10)
#    #   q = Porthos::Routing::Cache.new(Porthos::Routing::Cache::FILE_ON_DISK)
#    #   puts q.last_save_date
#    #   puts q.get.inspect
#
#    class CacheFileStore
#
#      def initialize(options = {})
#        @options = { :file_name => "routes_cache" }.merge(options)
#        store({}) unless exists?
#      end
#
#      def saved_at
#        File.stat(path).mtime
#      end
#
#      def retrive
#        Node.logger.warn("Fetching nodes file") if Routing.debug
#        Marshal.load File.read(path)
#      end
#
#      def store(object)
#        Node.logger.warn("Called CacheFileStore#store") if Routing.debug
#        File.open(path, 'w+') do |f|
#          f << Marshal.dump(object)
#        end
#      end
#
#    protected
#
#      def exists?
#        File.exists?(path)
#      end
#
#      def path
#        "#{Rails.root}/tmp/cache/#{@options[:file_name]}.marshal"
#      end
#
#    end
#
#    class MemCacheStore
#
#      def initialize(options = {})
#        namespace_key = ActionController::Base.session_options[:key]
#        @options = {
#          :storage_key   => 'routes',
#          :timestamp_key => 'routes_last_changed',
#          :host          => 'localhost',
#          :port          => 11211,
#          :namespace     => "#{namespace_key}-#{ENV['RAILS_ENV']}"
#        }.merge(options)
#        client.servers = "#{@options[:host]}:#{@options[:port]}"
#        client.set 'test', 'active'
#      end
#
#      def saved_at
#        client.get @options[:timestamp_key]
#      end
#
#      def retrive
#        Node.logger.warn("Fetching nodes from memcache") if Routing.debug
#        client.get @options[:storage_key]
#      end
#
#      def store(object)
#        Node.logger.warn("Called MemCacheStore#store") if Routing.debug
#        client.set @options[:storage_key], object
#        client.set @options[:timestamp_key], Time.now
#      end
#
#    protected
#
#      def client
#        @client ||= MemCache.new(:c_threshold => 10_000, :compression => true, :debug => false, :namespace => @options[:namespace], :readonly => false, :urlencode => false)
#      end
#
#    end
#
#  end
#end
#
#
#module ActionController
#  module Routing
#    class RouteSet
#      def recognize_with_porthos(request)
#        Porthos::Routing::Nodes.load!
#        return recognize_without_porthos(request)
#      end
#      alias_method_chain :recognize, :porthos
#    end
#  end
#end
