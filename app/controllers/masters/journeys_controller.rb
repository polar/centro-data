class Masters::JourneysController < ApplicationController


  # GET /journeys/1
  def show
    set_journey
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_journey
      @master = Master.find(params[:master_id])
      @journey = Journey.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def journey_params
      params[:journey]
    end
end
