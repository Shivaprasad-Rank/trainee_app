class AddcolumntoStudents < ActiveRecord::Migration
  def change
   add_column :students, :status ,:string
  end
end
