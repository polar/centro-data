class Api < ActiveRecord::Base
  serialize :box, Array

  belongs_to :master

  has_many :routes
  has_many :journeys

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "update"
          self.a_update= v
        when /oauth/
        when "time"
          self.time = Time.now
        when "timeoffset"
          self.time_offset= v
        when "box"
          self.box = v.split(",").map {|x| x.to_f}
        when "Message"
          # Not fully realized yet.
          if !v.is_a? Array
            v = [v]
          end
          for m in v do
            message = Message.new
            message.from_hash(m)
          end
        else
          self.send("#{k.underscore}=", v)
      end
    end
  end

end
