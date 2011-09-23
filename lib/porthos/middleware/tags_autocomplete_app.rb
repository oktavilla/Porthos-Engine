require 'rack/utils'
require 'singleton'
module Porthos
  module Middleware
    class TagsAutocompleteApp
      include Singleton

      attr_reader :params

      def call(env)
        @params = ::Rack::Utils.parse_query(env['QUERY_STRING'])
        [200, {}, self]
      end

      def each(&block)
        result.to_json.each(&block)
      end

    private

      def valid_request?
        params['term'].present? and %w(Page Asset).include?(params['taggable'])
      end

      def taggable
        params['taggable'].constantize
      end

      def result
        valid_request? ? tags : []
      end

      def tags
        taggable.all_tags(:'value.name' => /^#{params['term']}/).collect do |tag|
          tag.name.include?(Porthos::MongoMapper::Plugins::Taggable.delimiter) ? "\"#{tag.name}\"" : tag.name
        end
      end
    end
  end
end