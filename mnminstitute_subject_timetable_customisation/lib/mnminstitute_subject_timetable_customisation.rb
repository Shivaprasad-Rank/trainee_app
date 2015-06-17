# MnminstituteSubjectTimetableCustomisation
require 'dispatcher'
require 'overides/mnm_applicants_controller'
module MnminstituteSubjectTimetableCustomisation

  def self.attach_overrides
    Dispatcher.to_prepare  do
      ::ApplicantsController.instance_eval { include MnmApplicantsController }
    end
  end

  module MnmStudentProfile
    
    def self.included(base)
      base.class_eval do
        before_filter :mnm_student_profile, :only => [:profile]
      end

      def mnm_student_profile
        redirect_to :controller => "mnm_students", :action => "profile", :id => params[:id]
      end
    end
  end
  
  module MnmManageSubject
    def self.included(base)
      base.class_eval do
        before_filter :mnm_subject_list, :only => [:index]
      end

      def mnm_subject_list
        redirect_to :controller => "mnm_subjects", :action => "index", :id => params[:id]
      end
     
    end
  end

  module MnmAssessment
    def self.included(base)
      base.class_eval do
        before_filter :mnm_assessment_list, :only => [:show]
      end

      def mnm_assessment_list
        redirect_to :controller => "mnm_assessment_answers", :action => "show", :id => params[:id], :assignment_id => params[:assignment_id]
      end

    end
  end

  

  module MnmAssessmentChange
    def self.included(base)
      base.class_eval do
        before_filter :mnm_student_assessments, :only => [:index, :show, :new, :edit]
      end
      
      def mnm_student_assessments
        if params[:controller] == "assignments" and params[:action] == "index"
          redirect_to :controller => "mnm_assessments", :action => "index", :id => params[:id]
        elsif params[:controller] == "assignments" and params[:action] == "show"
          redirect_to :controller => "mnm_assessments", :action => "show", :id => params[:id]
        elsif params[:controller] == "assignments" and params[:action] == "new"
          redirect_to :controller => "mnm_assessments", :action => "new", :id => params[:id]
        else params[:controller] == "assignments" and params[:action] == "edit"
          redirect_to :controller => "mnm_assessments", :action => "edit", :id => params[:id]
        end
      end
    end
  end
      
  module MnmAssessmentFeature
    def self.included(base)
      base.class_eval do
        before_filter :mnm_assessment_answers, :only => [:new, :edit, :show]
      end
      def mnm_assessment_answers
        if params[:controller] == "assignment_answers" and params[:action] == "new"
          redirect_to :controller => "mnm_assessment_answers", :action => "new", :id => params[:id], :assignment_id => params[:assignment_id]
        elsif params[:controller] == "assignment_answers" and params[:action] == "show"
          redirect_to :controller => "mnm_assessment_answers", :action => "show", :id => params[:id]
        else params[:controller] == "assignment_answers" and params[:action] == "edit"
          redirect_to :controller => "mnm_assessment_answers", :action => "edit", :id => params[:id]
        end
      end
    end
  end

  module MnmRemarks
    def self.included(base)
      base.class_eval do
        before_filter :mnm_remarks_list, :only => [:generated_report3, :generated_report, :generated_report4, :list_subjects]
       
      end

      def mnm_remarks_list
        if params[:action] == "generated_report3"
          redirect_to :controller => "mnm_exams", :action => "generated_report3", :id => params[:id], :student => params[:student], :subject => params[:subject]
        elsif params[:action] == "generated_report"
          redirect_to :controller => "mnm_exams", :action => "generated_report", :id => params[:id], :exam_group => params[:exam_group], :student => params[:student]
        else params[:action] == "generated_report4"
          redirect_to :controller => "mnm_exams", :action => "generated_report4", :id => params[:id], :type => params[:type], :student => params[:student]
        
        end
      end
    end
  end
    
  module MnmClassList
    def self.included(base)
      base.class_eval do
        before_filter :mnm_class_list, :only => [:create_reminder]
      end

      def mnm_class_list
        redirect_to :controller => "mnm_class_list_reminders", :action => "create_reminder", :id => params[:id]
      end

    end
  end

  module MnmSharedTimetable
    def self.included(base)
      base.class_eval do
        before_filter :mnm_timetable, :only => [ :update_multiple_timetable_entries2, :tt_entry_update2, :tt_entry_noupdate2 ]
      end

      def mnm_timetable
        if params[:action] == "update_multiple_timetable_entries2"
          redirect_to :controller => "mnm_shared_timetable_entries", :action => "update_shared_timetable_entries2", :id => params[:id], :timetable_id => params[:timetable_id], :emp_sub_id => params[:emp_sub_id], :tte_ids => params[:tte_ids]
        else params[:action] == "tt_entry_update2"
          redirect_to :controller => "mnm_shared_timetable_entries", :action => "shared_tt_entry_update2", :id => params[:id], :timetable_id => params[:timetable_id], :batch_id => params[:batch_id], :employee_id => params[:emp_id], :subject_id => params[:sub_id], :tte_id => params[:tte_id]
        end
      end
    end
  end
end