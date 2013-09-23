class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :persistentid
      t.string :route_type
      t.string :name
      t.string :route_code
      t.float :sort
      t.integer :version
      t.float :nw_lon
      t.float :nw_lat
      t.float :se_lon
      t.float :se_lat
      t.string :patternids

      t.references :api
      t.references :master
    end
  end
end
