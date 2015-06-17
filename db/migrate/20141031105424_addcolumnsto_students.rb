class AddcolumnstoStudents < ActiveRecord::Migration
  def change
  add_column :students, :studentid_id ,:integer
  end
end
