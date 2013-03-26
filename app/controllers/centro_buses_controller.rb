class CentroBusesController < ApplicationController
  def index
    ignore = [:page, :action, :controller]
    if !params.except(*ignore).empty?
      @centro_buses = CentroBus.where(params.except(*ignore)).order(:created_at).paginate(:page => params[:page], :per_page => 30)
    else

    @centro_buses = CentroBus.order(:centroid, :created_at).paginate(:page => params[:page], :per_page => 30)
    end

  end

  def show
    @centro_bus = CentroBus.find(params[:id])
  end

  def new
    @centro_bus = CentroBus.new
  end

  def create
    @centro_bus = CentroBus.new(params[:centro_bus])
    if @centro_bus.save
      redirect_to @centro_bus, :notice => "Successfully created centro bus."
    else
      render :action => 'new'
    end
  end

  def edit
    @centro_bus = CentroBus.find(params[:id])
  end

  def update
    @centro_bus = CentroBus.find(params[:id])
    if @centro_bus.update_attributes(params[:centro_bus])
      redirect_to @centro_bus, :notice  => "Successfully updated centro bus."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @centro_bus = CentroBus.find(params[:id])
    @centro_bus.destroy
    redirect_to centro_buses_url, :notice => "Successfully destroyed centro bus."
  end
end
