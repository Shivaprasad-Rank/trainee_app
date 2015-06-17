# Include hook code here
require 'translator'
require File.join(File.dirname(__FILE__), "lib", "mnminstitute_subject_timetable_customisation")
config.after_initialize  do
  require File.join(File.dirname(__FILE__), "config", "initializers/mnm_i18n_initializer.rb")
end
FedenaPlugin.register = {
  :name=>"mnminstitute_subject_timetable_customisation",
  :description=>"Mnminstitute Subject Timetable Customisation",
  :auth_file=>"config/subject_timetable_auth.rb",
  :student_profile_more_menu => {
    :title=>"mnminstitute_student_report_title",
    :destination=>{:controller=>"student",:action=>"reports"}

  },
  :more_menu=>{:title=>"mnminstitute_subject_timetable_customisation_text",:controller=>"mnm_subjects",:action=>"index", :target_id=>"more-parent"}
}

Dir[File.join("#{File.dirname(__FILE__)}/config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end

MnminstituteSubjectTimetableCustomisation.attach_overrides

if RAILS_ENV == 'development'
  ActiveSupport::Dependencies.load_once_paths.\
    reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

require 'dispatcher'
Dispatcher.to_prepare do

  Student.send :has_many, :mnm_student_comments
  Student.send :has_many, :mnm_student_documents
  Subject.send :has_many, :mnm_subject_comments
  Subject.send :has_many, :mnm_subject_documents
  Subject.send :has_many, :mnm_shared_subjects
  Subject.send :has_many, :mnm_shared_subject_associations
  Subject.send :has_many, :mnm_class_lists
  Subject.send :has_many, :mnm_class_list_students
  AssignmentAnswer.send :has_many, :mnm_assessment_answers
  Assignment.send :has_many, :mnm_assessment_answers
  StudentController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmStudentProfile)
  SubjectsController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmManageSubject)
  AssignmentAnswersController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmAssessment)
  AssignmentAnswersController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmAssessmentFeature)
  AssignmentsController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmAssessmentChange)
  ExamController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmRemarks)
  ReminderController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmClassList)
  TimetableEntriesController.send(:include,MnminstituteSubjectTimetableCustomisation::MnmSharedTimetable)
end