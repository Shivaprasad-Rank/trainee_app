class AddImageFilenameToStudents < ActiveRecord::Migration
  def change
    add_column :students, :image_filename, :string
  end
end
