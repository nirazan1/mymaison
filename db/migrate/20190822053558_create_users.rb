class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :police_portal_username
      t.string :police_portal_password

      t.timestamps
    end
  end
end
