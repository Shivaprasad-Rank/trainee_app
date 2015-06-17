class AddcolumntoStudentids < ActiveRecord::Migration
  def change
 add_column :studentids, :idcards,:string
  end
end
