class AddColumnToStudents < ActiveRecord::Migration
  def change
  	change_column :students, :gender, :string
  #adding colum tostudents
  end
end
