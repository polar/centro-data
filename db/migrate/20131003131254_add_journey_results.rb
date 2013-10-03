class AddJourneyResults < ActiveRecord::Migration
  def change
    change_table :centro_buses do |t|
      t.text :journey_results
    end
  end
end
