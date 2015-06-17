class MnmClassListsController < ApplicationController

  def index
    @class_lists = MnmClassList.all
  end

  def new
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @class_list = MnmClassList.new
    else
      redirect_to :action => :index
    end
  end

  def create
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @subject = Subject.find_by_id(params[:subject][:id])
      if !@subject.nil?
        unless params[:student_ids].nil?
          if MnmSharedSubjectAssociation.exists?(:subject_id => @subject.id)
            @mnm_association =MnmSharedSubjectAssociation.find_by_subject_id(@subject.id)
            @class_list = MnmClassList.create(:subject_id => @subject.id, :subject_name => @subject.name, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id )
          else
            @class_list = MnmClassList.create(:subject_id => @subject.id, :subject_name => @subject.name )
          end
          params[:student_ids].each do |student_id|
            @student = Student.find_by_id(student_id)
            @mnm_class_list = MnmClassListStudent.create(:student_id => student_id, :mnm_class_list_id => @class_list.id )
            students = Student.find_all_by_id(student_id)
            students.collect(&:user_id).compact
            assigned_student_ids = students.collect(&:user_id).compact
            Delayed::Job.enqueue(
              DelayedReminderJob.new( :sender_id  => current_user.id,
                :recipient_ids => assigned_student_ids,
                :subject=>"#{t('assigned_to_subject')}",
                :body=>"#{@student.first_name} #{t('has_been_assigned_to')}  <br/> #{@subject.name}")
            )
            sms_setting = SmsSetting.new()
            if sms_setting.application_sms_active and @student.is_sms_enabled
              @recipients = []
              if sms_setting.student_sms_active
                @recipients.push @student.phone2 unless (@student.phone2.nil? or @student.phone2 == "")
              end
              message = "#{t('student_enrolled_to_subject')} #{@student.first_name}. #{t('subject_name')}: #{@class_list.subject_name}"
              Delayed::Job.enqueue(SmsManager.new(message,@recipients))
            end
          end
        end
      end
    end
    redirect_to :action => :index
  end

  def edit
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @class_list = MnmClassList.find(params[:id])
      @subject = Subject.find_by_id(@class_list.subject_id)
      @batch = Batch.find_by_id(@subject.batch_id)
      @course = Course.find_by_id(@batch.course_id)
      @batches = Batch.find_all_by_course_id(@course.id, :conditions => { :is_deleted => false, :is_active => true })
      @subjects = []
      @students = []
      @batches.each do |batch|
        @batch_subjects = Subject.find_all_by_batch_id(batch.id)
        @batch_students = Student.find_all_by_batch_id(batch.id)
        @batch_subjects.each do |subject|
          @subjects << subject
        end
        @batch_students.each do |student|
          @students << student
        end
      end
    else
      redirect_to :action => :index
    end
  end

  def update
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @class_list = MnmClassList.find(params[:id])
      @mnm_class_list_students = MnmClassListStudent.find_all_by_mnm_class_list_id(@class_list.id)
      if !@mnm_class_list_students.to_a.empty?
        if !params[:student_ids].to_a.empty?
          @mnm_class_list_students.each do |class_list_student|
            if params[:student_ids].include?(class_list_student.student_id.to_s)
              params[:student_ids] = params[:student_ids] - [class_list_student.student_id.to_s]
            else
              class_list_student.destroy
            end
          end
          params[:student_ids].each do |student_id|
            MnmClassListStudent.create(:student_id => student_id, :mnm_class_list_id => @class_list.id )
          end
        else
          @mnm_class_list_students.each do |mnm_class_list|
            mnm_class_list.destroy
          end
        end
      else
        if !params[:student_ids].to_a.empty?
          params[:student_ids].each do |student_id|
            MnmClassListStudent.create(:student_id => student_id, :mnm_class_list_id => @class_list.id )
          end
        end
      end
    end
    redirect_to :action => :index
  end

  def destroy
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @class_list = MnmClassList.find(params[:id])
      if @class_list.destroy
        @mnm_class_lists = MnmClassListStudent.find_all_by_mnm_class_list_id(@class_list.id)
        @mnm_class_lists.each do |mnm_class_list|
          mnm_class_list.destroy
        end
        redirect_to :action => :index
      end
    else
      redirect_to :action => :index
    end
  end

  def student
    @batches = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })
    @subjects = []
    @students = []
    @batches.each do |batch|
      @batch_subjects = Subject.find_all_by_batch_id(batch.id)
      @batch_students = Student.find_all_by_batch_id(batch.id)
      @batch_subjects.each do |subject|
        @subjects << subject
      end
      @batch_students.each do |student|
        @students << student
      end
    end
    respond_to do |format|
      format.js { render :action => 'student' }
    end
  end

  def show
    @class_list = MnmClassList.find(params[:id])
    @mnm_class_lists = MnmClassListStudent.find_all_by_mnm_class_list_id(@class_list.id)
    @classlist_students = []
    @mnm_class_lists.each do |mnm_class_list|
      @classlist_student = Student.find_by_id(mnm_class_list.student_id)
      if !@classlist_student.nil?
        @classlist_students << @classlist_student
      end
    end
  end
end
