require 'porthos/page_renderer'
module DefaultRenderer

  class Index < Porthos::PageRenderer

    def layout_class
      "#{@field_set.handle}-index"
    end

    def title
      @field_set.title
    end

    def page_id
      @field_set.handle
    end

    def pages
      return @pages if @pages
      scope = @field_set.pages.
                         published
      if params[:year]
        scope = scope.published_within(*Time.delta(params[:year], params[:month], params[:day]))
      end
      @pages = scope.paginate({
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 25),
        :order => 'pages.published_on DESC, pages.id DESC'
      }).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
    register_methods :pages

  end

  class Categories < Porthos::PageRenderer
    def categories
      return @categories if @categories
      @categories = Tag.on('Page').namespaced_to(@field_set.handle).all
      @categories
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
      @pages = Page.tagged_with(:tags => category.name, :namespace => @field_set.handle).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
  end

  class Show < Porthos::PageRenderer
    self.required_objects = [:field_set, :page]

    def layout_class
      @page.layout_class
    end

    def title
      @page.title
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
      @pages = Page.tagged_with(:tags => selected_tag_names).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end

    def tags
      @tags ||= Page.all_tags
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