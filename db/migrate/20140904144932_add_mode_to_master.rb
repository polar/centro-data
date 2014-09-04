class AddModeToMaster < ActiveRecord::Migration
  def change
    add_column :masters, :mode, :string
  end
end
