class CreatePatterns < ActiveRecord::Migration
  def change
    create_table :patterns do |t|
      t.string :persistentid
      t.string :route_type
      t.integer :version
      t.float :distance
      t.text :coords

      t.references :api
      t.references :master
      t.references :route
    end
  end
end
