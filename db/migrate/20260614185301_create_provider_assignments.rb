class CreateProviderAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_assignments do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.integer :plan, null: false, default: 0

      t.timestamps
    end

    add_index :provider_assignments, [:provider_id, :client_id], unique: true
  end
end
