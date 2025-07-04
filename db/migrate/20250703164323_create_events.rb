class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :subtitle
      t.string :location
      t.date :start_date
      t.date :end_date
      t.string :remarks
      t.integer :category
      t.string :highlight

      t.timestamps
    end
  end
end
