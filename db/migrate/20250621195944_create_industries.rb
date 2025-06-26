class CreateIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :industries do |t|
      t.text :name

      t.timestamps
      t.index :name, unique: true
    end
  end
end
