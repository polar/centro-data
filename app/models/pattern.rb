class Pattern < ActiveRecord::Base
  serialize :coords, Array
  belongs_to :api
  belongs_to :master
  belongs_to :route

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "id"
          self.persistentid = v
        when "type"
          self.route_type = v
        when "distance"
          self.distance = v.to_f
        when "JPs"
          self.coords = v["JP"].map{|x| [x["lon"].to_f,x["lat"].to_f] }
        else
          begin
            self.send("#{k.underscore}=", v)
          rescue
            puts "NO method for #{k.underscore}= #{v}"
          end
      end
    end

  end
end
