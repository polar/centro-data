class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :mid
      t.string :go_url
      t.integer :remind_period
      t.boolean :remindable
      t.datetime :expiry_time
      t.integer :version
      t.string :title
      t.text :content

      t.references :api
      t.references :master
    end
  end
end
