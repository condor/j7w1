class J7W1ApplicationDevices < ActiveRecord::Migration
  def change
    create_table :j7w1_application_devices do |t|
      t.string  :owner_type,          null: false
      t.integer :owner_id,            null: false
      t.string  :device_identifier,   null: false
      t.string  :platform,            null: false
      t.string  :device_endpoint_arn, null: true

      t.index [:owner_type, :owner_id]
      t.index [:device_identifier]
    end
  end
end
