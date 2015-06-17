authorization do

  role :subject_time_table_manager do
    has_permission_on [:mnm_students],
      :to => [:profile, :add_comment, :delete_comment, :comment_approved, :upload_document, :destroy, :download_attachment]
    has_permission_on [:mnm_subjects],
      :to => [:add_comment, :upload_document, :delete_comment, :index, :show_comment, :show, :subject_document, :download_attachment]
    has_permission_on [:mnm_assessment_answers],
      :to => [:show, :add_comment, :delete_comment, :comment_approved, :new, :show, :create, :edit, :update]
    has_permission_on [:mnm_assessments],
      :to => [:index, :show, :subject_assignments, :new, :subjects_students_list, :assignment_student_list, :create, :edit, :update, :destroy, :download_attachment]
    has_permission_on [:mnm_exams],
      :to => [:generated_report, :generated_report2, :generated_report3, :generated_report4, :grouped_exam_report, :list_subjects]
    has_permission_on [:mnm_shared_subjects],
      :to => [:index, :new, :create, :edit, :update, :destroy, :show, :assign_batches, :list_batch, :assign_shared_subjects, :shared_document_upload, :document_upload, :document_destroy]
    has_permission_on [:mnm_class_lists],
      :to => [:index, :new, :create, :edit, :update, :show, :destroy, :student]
    has_permission_on [:mnm_class_list_reminders],
      :to => [:create_reminder, :to_students, :select_employee_department, :select_student_course, :select_users, :select_parents]
    has_permission_on [:mnm_shared_timetable_entries],
      :to => [:update_shared_timetable_entries2, :tte_from_batch_and_tt, :shared_tt_entry_update2]
  end



  role :admin do
    includes :subject_time_table_manager
  end

  role :employee do
    includes :subject_time_table_manager
  end

  role :student do
    includes :subject_time_table_manager
  end

end