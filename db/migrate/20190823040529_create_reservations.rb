class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.date :checkin_date
      t.date :checkout_date
      t.references :property, index: true

      t.timestamps
    end
  end
end
