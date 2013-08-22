class Admin::NodesController < ApplicationController
  include Porthos::Admin

  def index
    respond_to do |format|
      format.html do
        @root  = Node.root
        if params[:partial]
          @node = params[:nodes] ? Node.find(params[:nodes].first) : @root
          render :partial => 'list_of_nodes.html.erb',
            :locals => { :nodes => @node.children, :trail => [], :place => (params[:place] || false) }
        else
          @nodes = @root ? @root.children : []
          @open_nodes = Node.find(params[:nodes])
          @trail = if @open_nodes.is_a?(Array)
            @open_nodes.collect { |node| (node.ancestors || []) << node }.flatten
          else
            []
          end
        end
      end
      format.json do
        @nodes = Node.all
        render json: @nodes.to_json
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
    @resource = Item.find(params[:resource_id]) if params[:resource_id]
    @node = @resource ? Node.for_item(@resource) : Node.new
    @nodes = [Node.root]
    respond_to do |format|
      format.html
    end
  end

  def create
    @node = Node.new(params[:node])
    respond_to do |format|
      if @node.save
        format.html {
          if @node.resource
            redirect_to admin_item_path(@node.resource.id)
          else
            redirect_to admin_nodes_path(:nodes => [@node])
          end
        }
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

  def toggle
    node = Node.find(params[:id])
    node.toggle!

    redirect_to params[:return_to] || edit_admin_node_path(node)
  end

  def edit
    @node = Node.find(params[:id])
    @nodes = [Node.root]
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def update
    @node = Node.find(params[:id])
    if @node.update_attributes(params[:node])
      flash[:notice] = t(:'app.admin_general.saved')
    end
    respond_to do |format|
      format.html do
        if @node.valid?
          redirect_to params[:return_to] || admin_nodes_path(:nodes => @node)
        else
          render action: (params[:place] ? 'place' : 'edit')
        end
      end
    end
  end

  def destroy
    node = Node.find(params[:id])
    node.destroy_children
    node.destroy_resource if node.resource
    node.destroy

    respond_to do |format|
      flash[:notice] = "#{node.name} #{t(:deleted, :scope => [:app, :admin_nodes])}"
      format.html { redirect_to admin_nodes_path }
    end
  end

  def sort
    params[:node].each_with_index do |id, i|
      object_id = BSON::ObjectId.from_string id
      Node.set(object_id, position: i+1)
    end

    render nothing: true
  end

end
