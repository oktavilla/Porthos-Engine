module Porthos
  class Routing
    # A rule is a hash with three keys
    # :test => Regexp to match the path
    # :matches => Array of names (param keys) for each match for the path regexp.
    # The first match should always be "url" (anything) before the params
    # :controller => The controller name for which this rule applies to
    # Example:
    #   {
    #     :test => /(^.*)\/(\d{4})\-(\d{2})\-(\d{2})/,
    #     :matches => ['url', 'year', 'month', 'day'],
    #     :controller => 'test_posts'
    #   }
    cattr_accessor :rules
    self.rules = [
      {
        :path => ":id",
        :constraints => {
          :id => '([a-z0-9\-\_]+)'
        },
        :controller => 'pages',
        :action => 'show'
      },
      {
        :path => ":year/:month/:day/:id",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})',
          :id => '([a-z0-9\-\_]+)'
        },
        :controller => 'pages',
        :action => 'show'
      },
      {
        :path => ":year/:month/:day",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})'
        },
        :controller => 'pages'
      },
      {
        :path => ":year/:month",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})'
        },
        :controller => 'pages'
      },
      {
        :path => ":year",
        :constraints => {
          :year => '(\d{4})'
        },
        :controller => 'pages'
      }
    ]

    # Find a rule definition that matches the path
    # Returns a hash of params
    def self.recognize(path)
      return {}.tap do |params|
        self.rules.sort_by { |r| r[:constraints].keys.size }.reverse.each do |rule|
          path_template = "^(.*|)/#{rule[:path].dup}"
          rule[:constraints].each do |key, value|
            path_template.gsub!(":#{key.to_s}", value)
          end
          matches = path.scan(Regexp.new(path_template)).flatten

          next unless matches.any?

          params[:url] = matches.shift.gsub(/^\//,'')
          keys = rule[:path].scan(/:(\w+)/).flatten
          keys.each_with_index do |key, i|
            params[key.to_sym] = matches[i]
          end
          params[:action] = rule[:action] if rule[:action]
          break
        end
      end
    end
  end
end