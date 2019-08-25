class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.string :signing_url
      t.string :signature_request_id
      t.boolean :contract_signed
      t.references :property, index: true

      t.timestamps
    end
  end
end
