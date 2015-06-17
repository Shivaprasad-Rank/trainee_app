class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
     t.string :cname
     t.string :cdesc
      t.timestamps
    end
  end
end
