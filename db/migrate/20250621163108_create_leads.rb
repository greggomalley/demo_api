class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.text :email, null: false
      t.text :name
      t.text :message
      t.references :user
      t.references :industry
      t.timestamps
    end
  end
end
