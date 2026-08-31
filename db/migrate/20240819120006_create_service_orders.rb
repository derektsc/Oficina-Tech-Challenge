class CreateServiceOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :service_orders do |t|
      t.string :number, null: false
      t.string :public_token, null: false
      t.references :customer, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.string :status, null: false, default: "received"
      t.decimal :budget_total, precision: 12, scale: 2, null: false, default: 0
      t.text :notes
      t.datetime :received_at
      t.datetime :diagnosis_started_at
      t.datetime :budget_sent_at
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :execution_started_at
      t.datetime :finished_at
      t.datetime :delivered_at
      t.timestamps
    end
    add_index :service_orders, :number, unique: true
    add_index :service_orders, :public_token, unique: true
    add_index :service_orders, :status
  end
end
