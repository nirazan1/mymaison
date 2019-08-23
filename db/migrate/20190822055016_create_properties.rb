class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
