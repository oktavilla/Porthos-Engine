class Admin::NodesController < ApplicationController
  include Porthos::Admin


  def index
    respond_to do |format|
      format.html do
        @root  = Node.root
        @nodes = @root ? @root.children : []
        @open_nodes = params[:nodes] ? Node.find_all_by_id(params[:nodes]) : Node.find_all_by_id(cookies[:last_opened_node])
        @trail = @open_nodes ? @open_nodes.collect { |node| (node.ancestors || []) << node }.flatten : []
      end
      format.js do
        @node = params[:nodes] ? Node.find(params[:nodes].first, :include => :children) : Node.root
        render :partial => 'admin/nodes/list_of_nodes.html.erb', :locals => { :nodes => @node.children.all, :trail => [], :place => (params[:place] || false) }
      end
    end
  end

  def show
    @node = Node.find(params[:id])
    respond_to do |format|
      format.html { redirect_to admin_nodes_path(:nodes => @node) }
      format.js { render :json => @node.to_json }
    end
  end

  def new
    @resource = Page.find(params[:resource_id]) if params[:resource_id]
    @node = @resource ? Node.for_page(@resource) : Node.new
    @nodes = [Node.root]
    respond_to do |format|
      format.html
    end
  end

  def create
    @node = Node.new(params[:node])
    respond_to do |format|
      if @node.save
        format.html { redirect_to admin_nodes_path(:nodes => @node) }
      else
        @resource = @node.resource
        @nodes = [Node.root]
        @open_nodes = [@node]
        format.html { render :action => 'new' }
      end
    end
  end

  def place
    @node = Node.find(params[:id])
    @nodes = [Node.root]
    ancestors = @node.ancestors
    ancestors.shift
    @trail = @node.ancestors << @node
    respond_to do |format|
      format.html do
        redirect_to admin_nodes_path unless Node.count > 1
      end
    end
  end

  def edit
    @node = Node.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def update
    @node = Node.find(params[:id])
    respond_to do |format|
      if @node.update_attributes(params[:node])
        format.html do
          redirect_to (params[:return_to] || admin_nodes_path(:nodes => @node))
        end
      else
        format.html do
          unless params[:place]
            render :action => 'edit'
          else
            @nodes = Node.roots
            render :action => 'place'
          end
        end
      end
    end
  end

  def destroy
    @node = Node.find(params[:id])
    @node.destroy
    respond_to do |format|
      flash[:notice] = "#{@node.name} #{t(:deleted, :scope => [:app, :admin_nodes])}"
      format.html { redirect_to admin_nodes_path }
    end
  end

  def sort
    params[:node].each_with_index do |id, i|
      if node = Node.find(id)
        node.update_attributes(:position => i+1)
      end
    end
    render :nothing => true
  end

end
