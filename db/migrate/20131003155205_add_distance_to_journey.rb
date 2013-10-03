class AddDistanceToJourney < ActiveRecord::Migration
  def change
    add_column :journeys, :path_distance, :float
  end
end
