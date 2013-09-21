class Route < ActiveRecord::Base
  serialize :patternids, Array
  belongs_to :api
  belongs_to :master

  has_many :patterns

  def bounds
    [nw_lon.to_f, nw_lat.to_f, se_lon.to_f, se_lat.to_f]
  end

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "__content__"
        when "patternids"
          self.patternids = v.split(",")
        when "type"
          self.route_type = v
        else
          self.send("#{k.underscore}=", v)
      end
    end

  end

end
