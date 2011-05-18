class Admin::DatumTemplatesController < ApplicationController
  include Porthos::Admin
  respond_to :html
  before_filter :find_page_template

  def new
    @datum_template = DatumTemplate.from_type(params[:template_type], params[:datum_template])
  end

  def create
    @datum_template = DatumTemplate.from_type(params[:template_type], params[:datum_template])
    @template.datum_templates << @datum_template
    if @datum_template.save
      flash[:notice] = "#{@datum_template.label}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @datum_template, :location => url_for(:controller => @template.class.to_s.tableize, :action => 'show', :id => @template.id.to_s)
  end

  def edit
    @datum_template = @template.datum_templates.find(params[:id])
  end

  def update
    @datum_template = @template.datum_templates.find(params[:id])
    if @datum_template.update_attributes(params[:datum_template])
      flash[:notice] = "#{@datum_template.label} #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @datum_template, :location => url_for(:controller => @template.class.to_s.tableize, :action => 'show', :id => @template.id.to_s)
  end

  def destroy
    @datum_template = @template.datum_templates.find(params[:id])
    if @template.pull(:datum_templates => { :_id => @datum_template.id })
      flash[:notice] = "#{@datum_template.label}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_with @datum_template, :location => url_for(:controller => @template.class.to_s.tableize, :action => 'show', :id => @template.id.to_s)
  end

  def sort
    if params[:datum_template]
      params[:datum_template].each_with_index do |id, i|
        @template.datum_templates.detect { |c| c.id.to_s == id }.tap do |datum_template|
          datum_template.position = i+1
        end
      end
      @template.save
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

protected

  def find_page_template
    @template = Template.find(params[:template_id])
  end

end