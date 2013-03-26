require "open-uri"
class CentroRoute

  attr_accessor :coordinates
  attr_accessor :pattern_code
  attr_accessor :route_code

  def self.url(route_code)
    "http://bus-time.centro.org/bustime/map/getRoutePoints.jsp?route=#{route_code}&key=0.9038479823691"
  end

  def self.retrieve(route_code)
    res = []
    route = Hash.from_xml open(url(route_code))
    if route
      routes = route["route"]["pas"]["pa"]
      for r in routes
        if !r["pt"].nil?
          if r["pt"].is_a? Array
            h = CentroRoute.new
            h.route_code=route["route"]["id"]
            h.pattern_code = r["id"]
            h.coordinates = r["pt"].map {|x| [x["lon"], x["lat"]] }
            res << h
          elsif r["pt"].is_a? Hash
          end
        end
      end
    end
    return res
  end

  def to_kml
    html = ""
    html += "<kml xmlns='http://earth.google.com/kml/2.0'>"
    html += "<Document><Folder><name>Route #{route_code} Pattern #{pattern_code}</name>"

    html += "<Placemark id='sp_0'><name>sp_0:First Bus Stop</name>"
    html += "<Point><coordinates>"
    html += "#{coordinates.first[0]}"
    html += ","
    html += "#{coordinates.first[1]}"
    html += "</coordinates></Point>"
    html += "</Placemark>"

    html += "<Placemark id='link_0'><name>link_0</name>"
    data = coordinates.map { |lon, lat| "#{lon},#{lat}" }.join(" ")
    html += "<LineString><coordinates>"
    html += data
    html += "</coordinates></LineString>"
    html += "</Placemark>"

    html += "<Placemark id='sp_1'><name>sp_1:Last Bus Stop</name>"
    html += "<Point><coordinates>"
    html += "#{coordinates.last[0]}"
    html += ","
    html += "#{coordinates.last[1]}"
    html += "</coordinates></Point>"
    html += "</Placemark>"

    html += "</Folder></Document>"
    html += "</kml>"
    html
  end
end