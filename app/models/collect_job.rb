require 'open-uri'

class CollectJob < Struct.new(:queue, :period, :route_codes)

  def enqueue(job)
    puts "Equeued Job #{queue} #{period} #{route_codes}."
  end

  def perform
    puts "Perform Job #{queue} #{period} #{route_codes}."
    for route_code in route_codes do
      resp = Hash.from_xml open("http://bus-time.centro.org/bustime/map/getBusesForRoute.jsp?route=#{route_code}&nsd=true&key=0.30387086560949683")
     # puts "got resp #{resp.inspect}"
      buses = resp["buses"]
      if ! buses["bus"].nil?
        if buses["bus"].is_a? Array
          puts "Got #{buses["bus"].count} bus locations for the #{route_code}."
          buses["bus"].map { |x| CentroBus.make(buses["time"], x) }
        elsif buses["bus"].is_a? Hash
          puts "Got 1 bus locations for the #{route_code}."
          CentroBus.make(buses["time"], buses["bus"])
        end
      end
    end

  rescue Exception => boom
    puts "Error #{boom}"
    p boom.backtrace
  ensure
    Delayed::Job.enqueue(self, :queue => queue, :run_at => Time.now + period.seconds)
  end
end