class CreateTableEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :payload
    end
  end
end
