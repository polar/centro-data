class Masters::PatternsController < ApplicationController

  # GET /patterns/1
  def show
    set_pattern
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pattern
      @master = Master.find(params[:master_id])
      @pattern = Pattern.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pattern_params
      params[:pattern]
    end
end
