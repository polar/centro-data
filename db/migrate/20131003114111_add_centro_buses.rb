class AddCentroBuses < ActiveRecord::Migration
  def change
    change_table :journeys do |t|
      t.string :time_zone
    end
  end
end
