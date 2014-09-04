class AddResetlocToApi < ActiveRecord::Migration
  def change
    add_column :apis, :resetloc, :string
  end
end
