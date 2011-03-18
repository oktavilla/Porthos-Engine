require 'porthos/page_renderer'
module DefaultRenderer

  class Index < Porthos::PageRenderer

    def pages
      return @pages if @pages
      field_set_ids = FieldSet.find(:all, :conditions => "handle IN('showcase', 'news')").collect(&:id)
      @pages = Page.published.
        include_restricted(true).
        find(:all, {
        :conditions => "field_set_id IN(#{field_set_ids.join(',')})",
        :limit => 5,
        :order => 'published_on desc'
      }).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
    register_methods :pages

    def calender_posts
      return @calender_posts if @calender_posts
      field_set = FieldSet.find_by_handle('event')
      return [] unless field_set
      scope = field_set.pages.
                        published.
                        include_restricted(true).
                        with_custom_attributes_field(:start_date)
      @calender_posts = scope.paginate({
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 5),
        :conditions => ['start_date.date_time_value >= ?', Time.now.beginning_of_day],
        :order => 'start_date.date_time_value'
      }).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
    register_methods :calender_posts

    def calender_posts_count
      return @calender_posts_count if @calender_posts_count
      field_set = FieldSet.find_by_handle('event')
      return 0 unless field_set
      field_set.pages.
                published.
                include_restricted(true).
                with_custom_attributes_field(:start_date).
                count(:conditions => ['start_date.date_time_value >= ?', Time.now.beginning_of_day])
    end
    register_methods :calender_posts_count

    def magazines
      @magazines ||= Magazine.find_random
    end
    register_methods :magazines

    def teasers
      @teasers ||= ContentLists.home.contents.find(:all, :include => :resource).collect do |c|
        c.respond_to?(:contents) ? c.contents.find(:all, :include => :resource) : c
      end.flatten.collect { |c| c.resource }
    end
    register_methods :teasers

  end

  class Categories < Porthos::PageRenderer
    def categories
      return @categories if @categories
      @categories = Tag.on('Page').namespaced_to(@field_set.handle).all
    end
    register_methods :categories
  end

  class Category < Porthos::PageRenderer
    def category
      return @category if @category
      @category = Tag.find_by_name(params[:id]) or raise ActiveRecord::RecordNotFound
    end
    register_methods :category

    def pages
      return @pages if @pages
      @pages = Page.find_tagged_with(:tags => category.name, :namespace => @field_set.handle).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
    register_methods :pages

  end

  class Show < Porthos::PageRenderer

    def layout_class
      @page.layout_class
    end

  protected

    def after_initialize
      @page.send :cache_custom_attributes
    end

  end

  class TaggedWith < Porthos::PageRenderer

    def categories
      @categories ||= Tag.on('Page').namespaced_to(@field_set.handle).all
    end

    def category
      nil
    end

    def pages
      return @pages if @pages
      @pages = Page.find_tagged_with(:tags => selected_tag_names, :conditions => ['pages.field_set_id = ?', @field_set.id]).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end

    def tags
      @tags ||= @field_set.tags_for_pages
    end

    def selected_tags
      if @selected_tags
        @selected_tags
      else
        @selected_tags = if params[:tags].present? && params[:tags].any?
          params[:tags].collect{|t| Tag.find_by_name(t) }.compact
        else
          []
        end
      end
    end

    def selected_tag_names
      return @selected_tag_names if @selected_tag_names.present?
      @selected_tag_names = if selected_tags && selected_tags.any?
        selected_tags.collect{|t| t.name }
      else
        []
      end
    end

    register_methods :categories, :category, :pages, :tags, :selected_tags, :selected_tag_names
  end
end
