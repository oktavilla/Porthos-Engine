require 'porthos/page_renderer'
module BlogRenderer

  class Index < Porthos::PageRenderer

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

    def node
      @node ||= @field_set.node
    end

    def title
      @title ||= String.new.tap do |_title|
        _title << @field_set.title
        _title << " - #{selected_year}" if params[:year]
        _title << "/#{selected_month}" if params[:month]
      end
    end

    def selected_year
      @selected_year ||= params[:year].present? ? params[:year].to_i : nil
    end

    def selected_month
      @selected_month ||= params[:month].present? ? params[:month].to_i : nil
    end

    def archive
      @archive ||= selected_year.present? ? field_set.dates_with_children(:year => selected_year) : field_set.dates_with_children
    end

    register_methods :pages, :node, :selected_year, :selected_month, :archive

  end

  class Show < Porthos::PageRenderer
    attr_accessor :page

    def layout_class
      @page.layout_class
    end

    def selected_year
      @selected_year ||= @page.published_on.year
    end

    def selected_month
      @selected_month ||= @page.published_on.month
    end

    def archive
      @archive ||= field_set.dates_with_children(:year => selected_year)
    end

    register_methods :selected_year, :selected_month, :archive

  protected

    def after_initialize
      @page.send :cache_custom_attributes
    end
  end
end
