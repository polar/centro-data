require "open-uri"

class MastersController < ApplicationController

  # GET /masters
  def index
    @masters = Master.all
  end

  # GET /masters/1
  def show
    set_master
    @api = @master.api
    if @api
      @routes = @api.routes
      @journeys = @api.journeys
    else
      RefreshJob.new(0).refresh_master(@master)
      redirect_to master_path(@master)
    end
  end

  # PATCH/PUT /masters/1
  def update
    set_master
    RefreshJob.new(0).refresh_master(@master)
    redirect_to master_path(@master)
  end

  def refresh
    url = "https://busme-apis.herokuapp.com/apis/d1/discover"
    url = "http://skylight.local:3002/apis/d1/discover"
    RefreshJob.new(0).refresh_masters(url)
    redirect_to masters_path
  end

  def reset
    set_master
    CentroBus.destroy_all
    redirect_to master_path(@master)
  end

  def locate
    set_master
    LocationJob.new(@master.id).doit
    redirect_to active_centro_buses_path(:master_id => @master.id)
  end

  # DELETE /masters/1
  def destroy
    set_master
    @master.destroy
    redirect_to masters_url, notice: 'Master was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master
      @master = Master.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def master_params
      params[:master]
    end
end
