class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.date :checkin_date, null: false
      t.date :checkout_date, null: false
      t.string :name, null: false
      t.string :email_address
      t.string :surname, null: false
      t.string :gender, null: false
      t.date :date_of_birth, null: false
      t.string :country_of_birth, null: false
      t.string :nationality, null: false
      t.string :passport_number
      t.boolean :group_leader, default: false
      t.boolean :synced_to_police_portal, default: false
      t.references :reservation, index: true

      t.timestamps
    end
  end
end
