class CreatePartnerServices < ActiveRecord::Migration[8.0]
  def change
    create_table :partner_services do |t|
      t.references :partner, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end

    # Keep the composite index to prevent duplicate partner-service pairs
    add_index :partner_services, [:partner_id, :service_id], unique: true
  end
end
