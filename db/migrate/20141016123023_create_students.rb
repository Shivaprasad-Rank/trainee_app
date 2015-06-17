class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
    	t.string :name
    	t.integer :phone
    	t.integer :age
    	t.text :address
    	t.string :email
     t.timestamps
    end
  end
end
