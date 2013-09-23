

class CentroBus < ActiveRecord::Base
  #attr_accessible :centroid, :rt, :d, :dd, :dn, :lat, :lon, :pid, :pd, :run, :fs, :op, :dip, :bid, :wid1, :wid2, :time


  attr_accessor :journey_results

  has_many :journeys
  belongs_to :journey

  def self.make(time, hash)
    hash["centroid"] = hash["id"]
    hash.delete("id")
    hash["time"] = time
    cb = CentroBus.where(:centroid => hash["centroid"]).first
    if cb.nil?
      cb = CentroBus.create(hash)
    else
      cb.update(hash)
    end
    return cb
  end


end
