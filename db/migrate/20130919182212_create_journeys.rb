class CreateJourneys < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.string :persistentid
      t.string :route_type
      t.string :dir
      t.float :sort
      t.string :route_code
      t.integer :version
      t.string :name
      t.boolean :timeless
      t.integer :start_offset
      t.integer :duration
      t.string :vid
      t.integer :location_refresh_rate
      t.float :nw_lon
      t.float :nw_lat
      t.float :se_lon
      t.float :se_lat
      t.string :patternid

      t.references :api
      t.references :pattern
      t.references :master
      t.references :route
      t.references :centro_bus
    end
  end
end
