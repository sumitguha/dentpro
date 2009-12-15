class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name
      t.string :description
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :region
      t.string :email
      t.string :phone1
      t.string :phone2
      t.string :fax
      t.string :url
      t.string :map_url
      t.string :photo_url
      t.integer :years_in_business
      t.string :service_areas
      t.string :hours_of_operation
      t.text :additional_info

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
