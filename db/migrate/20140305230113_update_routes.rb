class UpdateRoutes < ActiveRecord::Migration
  def change
    change_table :routes do |t|
      t.remove :patternids
      t.text :patternids
    end
  end
end
