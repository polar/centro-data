require "open-uri"
class CentroRoute

  attr_accessor :coordinates
  attr_accessor :pattern_code
  attr_accessor :route_code
  attr_accessor :stops
  attr_accessor :links

  class Stop
    attr_accessor :point
    attr_accessor :name
    attr_accessor :id

    def initialize

    end

    def to_kml(i = nil)
      name = self.name.gsub("<", "&lt;").gsub("&", "&amp;").gsub(">", "&gt;")
      if i
        kml = "<Placemark id='sp_#{i}'><name>sp_#{i}:#{name}</name>"
      else
        kml = "<Placemark><name>#{name}</name>"
      end

      kml += "<Point><coordinates>"
      kml += "#{point[0]}"
      kml += ","
      kml += "#{point[1]}"
      kml += "</coordinates></Point>"

      kml += "</Placemark>"
      kml
    end
  end

  class Link
    attr_accessor :coordinates
    attr_accessor :to, :from

    def initialize
      @coordinates = []
    end

    def to_journey_kml(i = nil)
      html = ""
      if i
        html += "<Placemark id='link_#{i}'><name>link_#{i}</name>"
      else
        html += "<Placemark>"
      end
      data = coordinates.map { |lon, lat| "#{lon},#{lat}" }.join(" ")
      html += "<LineString><coordinates>"
      html += data
      html += "</coordinates></LineString>"
      html += "</Placemark>"
      html
    end
  end

  def initialize
    @stops = []
    @links = []
  end


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
            link = Link.new
            r["pt"].each do |x|
              link.coordinates << [x["lon"], x["lat"]]
              if x["bs"]
                stop = Stop.new
                stop.id = x["bs"]["id"]
                stop.name = x["bs"]["st"]
                stop.point = [x["lon"],x["lat"]]
                link.to = stop
                h.stops << stop
                h.links << link
                link = Link.new
                link.from = stop
              end
            end
            # remove the first and last links
            h.links = h.links.take(h.links.length-1).drop(1)
            h.coordinates = r["pt"].map {|x| [x["lon"], x["lat"]] }
            res << h
          elsif r["pt"].is_a? Hash
          end
        end
      end
    end
    return res
  end

  def to_journey_kml
    html = ""
    html += "<kml xmlns='http://earth.google.com/kml/2.0'>"
    html += "<Document><Folder><name>Route #{route_code} Pattern #{pattern_code}</name>"

    sp_n = 0
    link_n = 0
    if links.nil? || links.length < 1
      raise "No Links"
    end
    html += links.first.from.to_kml(sp_n)
    links.each do |jptl|
      html += jptl.to_journey_kml(link_n)
      link_n += 1
      sp_n += 1
      html += jptl.to.to_kml(sp_n)
    end

    html += "</Folder></Document>"
    html += "</kml>"
    html
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