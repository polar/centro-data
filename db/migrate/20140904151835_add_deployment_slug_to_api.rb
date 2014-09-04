class AddDeploymentSlugToApi < ActiveRecord::Migration
  def change
    add_column :apis, :deployment_slug, :string
  end
end
