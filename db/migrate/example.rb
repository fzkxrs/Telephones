class CreateEmployees < ActiveRecord::Migration[6.1]
  def change
    create_table :employees do |t|
      t.string :company
      t.string :department
      t.string :name
      t.string :phone
      t.string :fax
      t.timestamps
    end
  end
end