class MnmSharedSubjectsController < ApplicationController

  def index
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @shared_subjects = MnmSharedSubject.all
    else
      redirect_to :controller => :user, :action => :dashboard
    end
  end

  def new
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @shared_subject = MnmSharedSubject.new
      @batch = Batch.find_by_id(params[:batch_id])
    else
      redirect_to :controller => :user, :action => :dashboard
    end
  end

  def create
    @shared_subject = MnmSharedSubject.new(params[:mnm_shared_subject])
    if @shared_subject.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "System Admin" or @current_user.admin?
      @shared_subject = MnmSharedSubject.find(params[:id])
    else
      redirect_to :controller => :user, :action => :dashboard
    end
  end

  def update
    @shared_subject = MnmSharedSubject.find(params[:id])
    if @shared_subject.update_attributes(params[:mnm_shared_subject])
      @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })
      @mnm_associations = MnmSharedSubjectAssociation.find_all_by_mnm_shared_subject_id(@shared_subject.id)
      @mnm_associations.each do |mnm_association|
        @assigned_subject = Subject.find(mnm_association.subject_id)
        @assigned_subject.update_attributes(:name => @shared_subject.name, :code => @shared_subject.code, :max_weekly_classes => @shared_subject.max_weekly_classes, :batch_id => mnm_association.batch_id)
      end
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def show
    @shared_subject = MnmSharedSubject.find(params[:id])
    @mnm_shared_subjects = MnmSharedSubjectAssociation.find_all_by_mnm_shared_subject_id(@shared_subject.id)
    @batches = []
    @mnm_shared_subjects.each do |shared_subject|
      @batch = Batch.find_by_id(shared_subject.batch_id)
      if !@batch.nil?
        @batches << @batch
      end
    end
  end

  def destroy
    @shared_subject = MnmSharedSubject.find(params[:id])
    if @shared_subject.destroy
      @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })
      @mnm_associations = MnmSharedSubjectAssociation.find_all_by_mnm_shared_subject_id(@shared_subject.id)
      @mnm_associations.each do |mnm_association|
        @assigned_subject = Subject.find(mnm_association.subject_id)
        @assigned_subject.destroy
        @mnm_association = MnmSharedSubjectAssociation.find_by_mnm_shared_subject_id(@shared_subject.id)
        @mnm_association.destroy
      end
      redirect_to :action => :index
    end
  end

  def assign_batches
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })
    @shared_subjects = MnmSharedSubject.all
  end

  def assign_shared_subjects
    @shared_subjects = MnmSharedSubject.all
    unless params[:batch_ids].nil?
      params[:batch_ids].each do |batch_id|
        unless params[:shared_subject_ids].nil?
          params[:shared_subject_ids].each do |shared_subject_id|
            @assigned_subject = MnmSharedSubject.find_by_id(shared_subject_id)
            if !Subject.exists?(:name =>@assigned_subject.name,:code => @assigned_subject.code, :batch_id => batch_id)
              @shared_subject = Subject.create(:name =>@assigned_subject.name,:code => @assigned_subject.code, :max_weekly_classes => @assigned_subject.max_weekly_classes, :batch_id => batch_id )
              @shared_subject =  MnmSharedSubjectAssociation.create(:mnm_shared_subject_id =>shared_subject_id, :subject_id => @shared_subject.id, :batch_id => batch_id)
            end
          end
        end
      end
    end
    redirect_to :action => "index"
  end

  def list_batch
    @shared_subjects = MnmSharedSubject.all
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })
    render(:update) do |page|
      page.replace_html 'list_batch', :partial=>'list_batch'
    end
  end

  def document_upload
    @document = MnmSubjectDocument.new(params[:mnm_subject_document])
    if @document.save
      redirect_to :action => :shared_document_upload, :id => @document.mnm_shared_subject_id
    else
      flash[:notice] = "Document Size should be less than 50 MB and Pdf, Jpeg, Mp4 Types"
      redirect_to :action => :shared_document_upload, :id => @document.mnm_shared_subject_id
    end
  end
  
  def shared_document_upload
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "Teaching" or @current_user.admin?
      @shared_subject = MnmSharedSubject.find(params[:id])
      @mnm_associations = MnmSharedSubjectAssociation.find_all_by_mnm_shared_subject_id(@shared_subject.id)
      @mnm_associations.each do |mnm_association|
        @assigned_subject = Subject.find_by_id(mnm_association.subject_id)
        @assigned_subject_docs = @assigned_subject.mnm_subject_documents
      end
    else
      redirect_to :action => :index
    end
  end

  def document_destroy
    @document = MnmSubjectDocument.find(params[:id])
    if @document.destroy
      redirect_to :action => :shared_document_upload, :id => @document.mnm_shared_subject_id
    end
  end


end
