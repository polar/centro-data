class CreateUserLogins < ActiveRecord::Migration
  def change
    create_table :user_logins do |t|
      t.string :name
      t.string :email
      t.string :roles
      t.string :role_intent
      t.string :auth_token
      t.string :status
      t.references :api
      t.references :master
    end
  end
end
