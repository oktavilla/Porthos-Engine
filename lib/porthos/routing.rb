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
    # self.rules = [
    #   {
    #     :test => /(^.*)\/(\d+)\-[a-z0-9]/,
    #     :matches => ['url', 'id'],
    #     :controller => 'pages'
    #   },
    #   {
    #     :test => /(^.*)\/(\d{4})\/(\d{2})\/(\d{2})\/(\d+)/,
    #     :matches => ['url', 'year', 'month', 'day', 'id'],
    #     :controller => 'pages'
    #   },
    #   {
    #     :test => /(^.*)\/(\d{4})\/(\d{2})\/(\d{2})$/,
    #     :matches => ['url', 'year', 'month', 'day'],
    #     :controller => 'pages'
    #   },
    #   {
    #     :test => /(^.*)\/(\d{4})\/(\d{2})$/,
    #     :matches => ['url', 'year', 'month'],
    #     :controller => 'pages'
    #   },
    #   {
    #     :test => /(^.*)\/(\d{4})$/,
    #     :matches => ['url', 'year'],
    #     :controller => 'pages'
    #   }
    # ]
    self.rules = [
      {
        :test => ":url/:id",
        :constraints => {
          :url => '(^.*)',
          :id => '(\d+)\-[a-z0-9]'
        },
        :controller => 'pages'
      },
      {
        :test => ":url/:year/:month/:day/:id",
        :constraints => {
          :url => '(^.*)',
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})',
          :id => '(\d+\-.*)'
        },
        :controller => 'pages',
        :action => 'show'
      },
      {
        :test => ":url/:year/:month/:day",
        :constraints => {
          :url => '(^.*)',
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})'
        },
        :controller => 'pages'
      },
      {
        :test => ":url/:year/:month",
        :constraints => {
          :url => '(^.*)',
          :year => '(\d{4})',
          :month => '(\d{2})'
        },
        :controller => 'pages'
      },
      {
        :test => ":url/:year/:month",
        :constraints => {
          :url => '(^.*)',
          :year => '(\d{4})'
        },
        :controller => 'pages'
      }
    ]

    # Find a rule definition that matches the path
    # Returns a hash of params
    def self.recognize(path)
      return {}.tap do |params|
        self.rules.each do |rule|
          path_template = rule[:test].dup
          rule[:constraints].each do |key, value|
            path_template.gsub!(":#{key.to_s}", value)
          end
          matches = path.match(Regexp.new(path_template)).to_a
          next unless matches.any?

          matches.shift
          keys = rule[:test].scan(/:(\w+)/).flatten
          keys.each_with_index do |key, i|
            params[key.to_sym] = matches[i]
          end
          params[:action] = rule[:action] if rule[:action]
        end
      end
    end
  end
end