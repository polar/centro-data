class CreateCentroBuses < ActiveRecord::Migration
  def change
    create_table :centro_buses do |t|
      t.string    :centroid
      t.string    :rt
      t.string    :rtdd
      t.string    :d
      t.string    :dd
      t.string    :dn
      t.float     :lat
      t.float     :lon
      t.string    :pid
      t.string    :pd
      t.string    :run
      t.string    :fs
      t.string    :op
      t.integer   :dip
      t.integer   :bid
      t.string    :wid1
      t.string    :wid2
      t.string    :time

      t.references :journey
      t.timestamps
    end
  end
end
