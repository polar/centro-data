class AddDeploymentSlugToMaster < ActiveRecord::Migration
  def change
    add_column :masters, :deployment_slug, :string
  end
end
