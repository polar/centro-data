class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.integer :major_version
      t.integer :minor_version
      t.string :mode
      t.string :name
      t.string :slug
      t.string :auth
      t.string :login
      t.string :register
      t.string :logout
      t.integer :postloc_time_rate
      t.integer :postloc_dist_rate
      t.integer :curloc_time_rate
      t.integer :marker_time_rate
      t.float :lon
      t.float :lat
      t.string :timezone
      t.datetime :time
      t.string :time_offset
      t.string :datefmt
      t.string :get_route_journey_ids
      t.string :get_route_definition
      t.string :get_journey_location
      t.string :get_multiple_journey_locations
      t.string :post_journey_location
      t.string :get_messages
      t.string :get_markers
      t.string :post_feedback
      t.string :a_update
      t.integer :update_rate
      t.integer :active_start_display_threshold
      t.integer :active_end_wait_threshold
      t.float :off_route_distance_threshold
      t.float :off_route_time_threshold
      t.integer :off_route_count_threshold
      t.string :get_route_journey_ids1
      t.integer :sync_rate
      t.integer :banner_refresh_rate
      t.integer :banner_max_image_size
      t.string :help_url
      t.string :box
      t.string :marker_click_thru
      t.string :message_click_thru
      t.string :banner_click_thru
      t.string :banner_image

      t.references :master
    end
  end
end
