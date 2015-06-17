class CreateColleges < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
    	t.string :name
    	t.string :coladd
    	t.string :image
      t.timestamps
    end
  end
end
