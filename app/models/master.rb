class Master < ActiveRecord::Base
  serialize :bounds, Array

  has_one :api, :dependent => :destroy

  has_many :journeys, :dependent => :destroy
  has_many :routes, :dependent => :destroy
  has_many :patterns, :dependent => :destroy


  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "api"
          self.api_url = v
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
