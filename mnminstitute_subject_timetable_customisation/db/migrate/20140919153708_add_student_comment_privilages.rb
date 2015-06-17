class AddStudentCommentPrivilages < ActiveRecord::Migration
  def self.up
    Privilege.find_or_create_by_name :name => "StudentCommentManager", :description => 'student_comment_manager', :privilege_tag_id => PrivilegeTag.find_by_name_tag('student_management').id
  end

  def self.down
    privilege = Privilege.find_by_name("StudentCommentManager")
    privilege.destroy unless privilege.nil?
  end
end
