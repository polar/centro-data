class Masters::JourneysController < ApplicationController

  def index
    set_master
    @time_now = Time.now.in_time_zone("America/New_York")
    @api = @master.api
    if @api
      @routes = @api.routes
      @journeys = @api.journeys
      @centro_buses = CentroBus.order(:centroid).to_a
    end
  end

  # GET /journeys/1
  def show
    set_journey
  end

  private

    def set_master
      @master = Master.find(params[:master_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_journey
      set_master
      @journey = Journey.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def journey_params
      params[:journey]
    end
end
