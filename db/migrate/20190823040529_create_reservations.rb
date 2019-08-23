class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.date :checkin_date, null: false
      t.date :checkout_date, null: false
      t.references :property, index: true

      t.timestamps
    end
  end
end
