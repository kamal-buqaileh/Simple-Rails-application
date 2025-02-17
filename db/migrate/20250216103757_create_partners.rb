class CreatePartners < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'postgis' unless extension_enabled?('postgis')

    create_table :partners do |t|
      t.string :name, null: false
      t.column :geog, 'geography(Point,4326)', null: false
      t.float :operating_radius, null: false
      t.float :rating, null: false, default: 0.0

      t.timestamps
    end

    add_index :partners, :geog, using: :gist  # GIST index for spatial queries
    add_index :partners, :rating
  end
end
