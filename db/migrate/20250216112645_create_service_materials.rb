class CreateServiceMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :service_materials do |t|
      t.references :service, null: false, foreign_key: true
      t.references :material, null: false, foreign_key: true

      t.timestamps
    end

    # Keep the composite index to prevent duplicate service-material pairs
    add_index :service_materials, [ :service_id, :material_id ], unique: true
  end
end
