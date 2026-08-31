class CreateVehicles < ActiveRecord::Migration[7.2]
  def change
    create_table :vehicles do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :plate, null: false
      t.string :brand, null: false
      t.string :model, null: false
      t.integer :year, null: false
      t.timestamps
    end
    add_index :vehicles, :plate, unique: true
  end
end
