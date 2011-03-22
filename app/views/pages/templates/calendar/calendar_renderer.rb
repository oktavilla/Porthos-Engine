require 'porthos/page_renderer'
module CalendarRenderer

  def self.dates_for_archive(field_set, current_year = Time.now.year)
   years = ActiveRecord::Base.connection.select_values("select distinct year(calendar_date.date_time_value) as year from pages
                                     left join custom_attributes as calendar_date on calendar_date.context_type = 'Page' and
                                               calendar_date.context_id = pages.id and calendar_date.handle = 'calendar_date'
                                      where field_set_id = #{ field_set.id } and published_on <= now()
                                      order by year desc")
    years.collect do |year|
      months = ActiveRecord::Base.connection.select_values("select distinct month(calendar_date.date_time_value) as month, year(calendar_date.date_time_value) as year from pages
                                         left join custom_attributes as calendar_date on calendar_date.context_type = 'Page' and
                                                   calendar_date.context_id = pages.id and calendar_date.handle = 'calendar_date'
                                         where year(calendar_date.date_time_value) = #{ current_year } and
                                               field_set_id = #{ field_set.id } and published_on <= now()
                                         order by month desc")
      [year, months.collect { |month| "%02d" % month }.sort ]
    end
  end

  class Index < Porthos::PageRenderer

    def pages
      return @pages if @pages
      scope = @field_set.pages.
                         published.
                         with_custom_attributes_field(:calendar_date)
      if params[:year]
        calendar_start, calendar_end = Time.delta(params[:year], params[:month], params[:day])
        calendar_where = ['calendar_date.date_time_value BETWEEN ? AND ?', calendar_start.to_s(:db), calendar_end.to_s(:db)]
      else
        calendar_where = ['calendar_date.date_time_value >= ?', Time.now.beginning_of_day]
      end
      @pages = scope.paginate({
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 25),
        :conditions => calendar_where,
        :order => 'calendar_date.date_time_value'
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
      @selected_month ||= params[:month].present? ? params[:month] : nil
    end

    def archive
      @archive ||= selected_year.present? ? CalendarRenderer.dates_for_archive(@field_set, selected_year) : CalendarRenderer.dates_for_archive(@field_set)
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
      @archive ||= CalendarRenderer.dates_for_archive(@page.field_set, selected_year)
    end

    register_methods :selected_year, :selected_month, :archive

  protected

    def after_initialize
      @page.send :cache_custom_attributes
    end
  end
end
