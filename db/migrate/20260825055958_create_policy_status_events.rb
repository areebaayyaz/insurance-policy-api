class CreatePolicyStatusEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :policy_status_events do |t|
      t.references :policy, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.string :reason
      t.datetime :occurred_at, null: false
      t.datetime :created_at, null: false
    end

    add_index :policy_status_events, [:policy_id, :occurred_at]
  end
end
