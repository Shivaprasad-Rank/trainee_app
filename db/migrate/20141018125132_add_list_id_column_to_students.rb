class AddListIdColumnToStudents < ActiveRecord::Migration
  def change
    add_column :students, :gender, :boolean
  end
end
