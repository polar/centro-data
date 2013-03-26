class CentroRoutesController < ApplicationController
  def index
    @centro_route_codes = [43,243,443,643,44,144,244,344,45]
  end

  def show
    @centro_routes = CentroRoute.retrieve(params[:id])
  end

  def download
    routes = CentroRoute.retrieve(params[:id])
    route = routes.select {|x| x.pattern_code == params[:pattern]}
    if route && route.count == 1
      if params[:with_stops]
        send_data route[0].to_journey_kml, :filename => "Route #{route[0].route_code} Pattern #{route[0].pattern_code}.kml", :content_type => "application/xml"
      else
        send_data route[0].to_kml, :filename => "Route #{route[0].route_code} Pattern #{route[0].pattern_code}.kml", :content_type => "application/xml"
      end
    else
      send_data "No KML", :content_type => "application/text"
    end
  end
end
