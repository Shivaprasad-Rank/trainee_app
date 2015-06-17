class CreateMnmSharedTimetableAssociations < ActiveRecord::Migration
  def self.up
    create_table :mnm_shared_timetable_associations do |t|
      t.integer :mnm_shared_subject_id
      t.integer :timetable_entry_id
      t.integer :timetable_id
      t.integer :school_id
      t.integer :subject_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_shared_timetable_associations
  end
end
