class MnmClassListRemindersController < ApplicationController

  def create_reminder
    @user = current_user
    if @user.admin?
      @departments = EmployeeDepartment.ordered(:select=>'employee_departments.*, count(employees.id) as emp_count',:joins=>:employees,:group=>"employee_departments.id",:having=>"emp_count>0")
      @batches=Batch.all(:select=>'batches.*, count(students.id) as stu_count,courses.code',:joins=>[:students,:course],:group=>"batches.id",:having=>"stu_count>0",:conditions=>["batches.is_deleted = ? and batches.is_active = ?",false,true],:order=>"courses.code ASC")
      @parents_for_batch =Batch.all(:select=>'batches.*, count(students.id) as stu_count,courses.code,count(guardians.id) as guard_count',:joins=>[[:students=>:guardians],:course],:group=>"batches.id",:having=>"stu_count>0 and guard_count>0",:conditions=>["batches.is_deleted = ? and batches.is_active = ?",false,true],:order=>"courses.code ASC")
    end
    if @user.student?
      @batches=@user.student_record.batch.to_a
      @parents_for_batch=@user.student_record.batch.to_a if @user.student_record.immediate_contact.present?
      @departments=[]
      if @user.student_record.batch.employees.present?
        @user.student_record.batch.employees.each do |employee|
          @departments<<employee.employee_department
        end
      end
      if @user.student_record.subjects.present?
        @user.student_record.subjects.each do |subject|
          if subject.employees.present?
            subject.employees.each do |employee|
              @departments<<employee.employee_department
            end
          end
        end
      end
      if @user.student_record.batch.subjects.present?
        @user.student_record.batch.subjects.all(:conditions=>["elective_group_id IS NULL"]).each do |subject|
          if subject.employees.present? and subject.batch_id==@user.student_record.batch_id
            subject.employees.each do |employee|
              @departments<<employee.employee_department
            end
          end
        end
      end
      @departments.uniq!
    end
    if @user.parent?
      @students=Student.find_all_by_sibling_id(Guardian.find_by_user_id(@user.id).ward_id)
      @batches=[]
      @subjects=[]
      @normal_subjects=[]
      if @students.present?
        @students.each do |student|
          @batches+=student.batch.to_a
          @subjects+=student.subjects
          @normal_subjects+=student.batch.subjects.all(:conditions=>["elective_group_id IS NULL"])
        end
      end
      @batches.uniq!
      @subjects.uniq!
      @normal_subjects.uniq!
      @parents=[]
      @departments=[]
      if @batches.present?
        @batches.each do |batch|
          if batch.employees.present?
            batch.employees.each do |employee|
              @departments<<employee.employee_department
            end
          end
        end
      end
      if @subjects.present?
        @subjects.each do |subject|
          if subject.employees.present?
            subject.employees.each do |employee|
              @departments<<employee.employee_department
            end
          end
        end
      end
      if @normal_subjects.present?
        @normal_subjects.each do |subject|
          if subject.employees.present?
            subject.employees.each do |employee|
              @departments<<employee.employee_department
            end
          end
        end
      end
      @departments.uniq!
    end
    if @user.employee? and !@user.has_required_control?
      @departments = EmployeeDepartment.ordered(:select=>'employee_departments.*, count(employees.id) as emp_count',:joins=>:employees,:group=>"employee_departments.id",:having=>"emp_count>0")
      @batches=Batch.all(:select=>'batches.*, count(students.id) as stu_count,courses.code',:joins=>[:students,:course],:group=>"batches.id",:having=>"stu_count>0",:conditions=>["batches.is_deleted = ? and batches.is_active = ?",false,true],:order=>"courses.code ASC")
    end
    if @user.employee? and @user.has_required_control?
      @departments = EmployeeDepartment.ordered(:select=>'employee_departments.*, count(employees.id) as emp_count',:joins=>:employees,:group=>"employee_departments.id",:having=>"emp_count>0")
      @batches=Batch.all(:select=>'batches.*, count(students.id) as stu_count,courses.code',:joins=>[:students,:course],:group=>"batches.id",:having=>"stu_count>0",:conditions=>["batches.is_deleted = ? and batches.is_active = ?",false,true],:order=>"courses.code ASC")
      @parents_for_batch=[]
      if @user.employee_record.subjects.present?
        @user.employee_record.subjects.each do |subject|
          subject.batch.students.each do |student|
            @parents_for_batch<<student.batch unless student.immediate_contact.nil?
          end
        end
      end
      if @user.employee_record.batches.present?
        @user.employee_record.batches.each do |batch|
          batch.students.each do |student|
            @parents_for_batch<<student.batch unless student.immediate_contact.nil?
          end
        end
      end
      @parents_for_batch.uniq!
    end

    @new_reminder_count = Reminder.find_all_by_recipient(@user.id, :conditions=>"is_read = false")
    unless params[:send_to].nil?
      recipients_array = params[:send_to].split(",").collect{ |s| s.to_i }
      @recipients = User.active.find(recipients_array,:order=>"first_name ASC")
    end

    if current_user.employee? or current_user.admin?
      @employee = Employee.find_by_user_id(current_user.id)
      @employee_subjects = @employee.subjects
      @class_lists = []
      if !@employee_subjects.empty?
        @employee_subjects.each do |emp_sub|
          @class_list = MnmClassList.find_by_subject_id(emp_sub.id)
          if !@class_list.nil?
            @class_lists << @class_list
          end
        end
      end
    else
      render :action=>'create_reminder'
    end

    if request.post?
      unless params[:reminder][:body].blank? or (params[:recipients_employees].blank? and params[:recipients_students].blank? and params[:recipients_parents].blank?) or params[:reminder][:subject].blank?

        recipients_array =[]
        recipients_array += params[:recipients_employees].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i } unless params[:recipients_employees].blank?
        recipients_array += params[:recipients_students].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i } unless params[:recipients_students].blank?
        #        recipients_array += params[:recipients_parents].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i } unless params[:recipients_parents].blank?
        unless params[:recipients_parents].blank?
          student_ids=params[:recipients_parents].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i } unless params[:recipients_parents].blank?
          @students=Student.find(:all,:conditions=>["user_id in (?)",student_ids])
          @parent_ids=[]
          @students.each do |student|
            @parent_ids<<student.immediate_contact.user_id unless student.immediate_contact.nil?
          end
          recipients_array +=@parent_ids
        end
        Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => @user.id,
            :recipient_ids => recipients_array,
            :subject=>params[:reminder][:subject],
            :body=>params[:reminder][:body] ))
        flash[:notice] = "#{t('reminder_flash1')}"
        redirect_to :controller=>"reminder", :action=>"create_reminder"
      else
        if params[:recipients_employees].present? or params[:recipients_students].present? or params[:recipients_parents].present?

          @user = current_user
          #          @departments = EmployeeDepartment.find(:all)
          @new_reminder_count = Reminder.find_all_by_recipient(@user.id, :conditions=>"is_read = false")
          recipients_array=[]
          unless params[:recipients_employees].blank?
            p "came heer"
            recipients_array += params[:recipients_employees].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i }
            @recipients_employees = User.active.find(params[:recipients_employees].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i },:order=>"first_name ASC")
          end
          unless params[:recipients_students].blank?
            recipients_array += params[:recipients_students].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i }
            @recipients_students = User.active.find(params[:recipients_students].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i },:order=>"first_name ASC")
          end
          unless params[:recipients_parents].blank?
            recipients_array += params[:recipients_parents].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i }
            @recipients_parents = User.active.find(params[:recipients_parents].split(",").reject{|a| a.strip.blank?}.collect{ |s| s.to_i },:order=>"first_name ASC")
          end
          if params[:reminder][:subject].present?
            @subject=params[:reminder][:subject]
          else
            @subject=""
          end
          if params[:reminder][:body].present?
            @body=params[:reminder][:body]
          else
            @body=""
          end

          flash[:notice]="<b>ERROR:</b>#{t('reminder_flash6')}"
          render :action=>'create_reminder'
        else
          if params[:reminder][:subject].present?
            @subject=params[:reminder][:subject]
          else
            @subject=""
          end
          if params[:reminder][:body].present?
            @body=params[:reminder][:body]
          else
            @body=""
          end
          flash[:notice]="<b>ERROR:</b>#{t('reminder_flash7')}"
          render :action=>'create_reminder'
          #          redirect_to :controller=>"reminder", :action=>"create_reminder"
        end
      end
    end
  end

  def to_students
    @class_list = MnmClassList.find(params[:mnm_class_list_id])
    @mnm_class_lists = MnmClassListStudent.find_all_by_mnm_class_list_id(@class_list.id)
    @students = []
    @mnm_class_lists.each do |mnm_class_list|
      @classlist_student = Student.find_by_id(mnm_class_list.student_id)
      if !@classlist_student.nil?
        @students << @classlist_student
      end
    end
    students = @students.sort_by{|a| a.full_name.downcase}
    @to_students = students.map { |s| s.user.id unless s.user.nil? }
    @to_students.delete nil
    render :update do |page|
      page.replace_html 'to_students2', :partial => 'to_students', :object => @to_users
    end
  end

  def select_employee_department
    @user = current_user
    if @user.admin? or @user.employee?
      @departments = EmployeeDepartment.active_and_ordered
    elsif @user.parent?
      @departments =[]
    end

    render :partial=>"select_employee_department"
  end

  def select_student_course
    @user = current_user
    if @user.admin? or @user.employee?
      @batches = Batch.active
    elsif @user.student?
      @batches = @user.student_record.batch.to_a
    elsif @user.parent?
      @batches =""
    end
    render :partial=> "select_student_course"
  end

  def select_users
    @user = current_user
    users = User.active.find(:all, :conditions=>"student = false")
    @to_users = users.map { |s| s.id unless s.nil? }
    render :partial=>"to_users", :object => @to_users
  end

  def select_parents
    @user = current_user
    if @user.admin?
      @parents_for_batch = Batch.active
    elsif @user.employee? and @user.has_required_control?
      @parents=[]
      @parents+=@user.employee_record.batches
      @user.employee_record.subjects.each do |subject|
        @parents<<subject.batch
      end
      @parents.uniq!
    elsif @user.student?
      @parents = @user.student_record.immediate_contact.to_a
    elsif @user.parent?
      @parents =""
    end
    render :partial=> "select_student_course"
  end
end
