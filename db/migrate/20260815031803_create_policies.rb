class CreatePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :policies do |t|
      t.string :policy_number
      t.string :holder_name
      t.string :status, default: "pending", null: false
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
