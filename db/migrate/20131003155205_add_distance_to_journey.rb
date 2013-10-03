class AddDistanceToJourney < ActiveRecord::Migration
  def change
    add_column :journeys, :distance, :float
  end
end
