class CreateStudentids < ActiveRecord::Migration
  def change
    create_table :studentids do |t|
    	t.string :name
    	t.string :descp 
      t.timestamps
    end
  end
end
