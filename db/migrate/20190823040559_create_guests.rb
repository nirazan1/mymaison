class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :name
      t.string :surname
      t.string :gender
      t.date :date_of_birth
      t.string :country_of_birth
      t.string :nationality
      t.string :passport_number
      t.boolean :group_leader
      t.references :reservation, index: true

      t.timestamps
    end
  end
end
