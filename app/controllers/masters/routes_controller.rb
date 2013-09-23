class Masters::RoutesController < ApplicationController

  # GET /masters/:master_id/routes
  def index
    @master = Master.find(params[:master_id])
    @routes = @master.routes
    @journeys = @master.journeys
  end

  # GET /routes/1
  def show
    set_route
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @master = Master.find(params[:master_id])
      @route = Route.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def route_params
      params[:route]
    end
end
