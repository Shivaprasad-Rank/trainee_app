class CreateMnmSharedSubjects < ActiveRecord::Migration
  def self.up
    create_table :mnm_shared_subjects do |t|
      t.string   :name
      t.string   :code
      t.integer  :max_weekly_classes
      t.boolean  :no_exams, :default=>false
      t.boolean  :is_deleted, :default=>false
      t.references :elective_group
      t.integer  :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_shared_subjects
  end
end
