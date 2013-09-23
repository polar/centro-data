class CreateMasters < ActiveRecord::Migration
  def change
    create_table :masters do |t|
      t.string :name
      t.string :slug
      t.float :lon
      t.float :lat
      t.string :bounds
      t.string :api_url
      t.string :title
      t.text :description

      t.references :api
    end
  end
end
