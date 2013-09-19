require 'open-uri'

class BusmeRoutesJob < Struct.new(:queue, :period)
  def perform
    puts "Perform Job #{queue} #{period} #{route_codes}."
    for route_code in route_codes do
      resp = Hash.from_xml open("https://busme-apis.herokuapp.com/apis/1/discover")

end
