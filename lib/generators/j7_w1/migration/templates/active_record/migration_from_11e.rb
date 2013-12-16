class J7W1MigrateBefore11 < ActiveRecord::Migration
  def change
    change_table :j7w1_application_devices do |t|
      t.boolean :disabled,            null: false,  default: false
    end
  end
end
