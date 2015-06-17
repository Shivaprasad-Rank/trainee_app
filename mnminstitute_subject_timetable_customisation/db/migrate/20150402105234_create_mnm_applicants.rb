class CreateMnmApplicants < ActiveRecord::Migration
  def self.up
    create_table :mnm_applicants do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_applicants
  end
end
