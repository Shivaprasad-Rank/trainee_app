class AddColumnToColleges < ActiveRecord::Migration
  def change
    add_column :colleges, :colname, :string
  end
end
