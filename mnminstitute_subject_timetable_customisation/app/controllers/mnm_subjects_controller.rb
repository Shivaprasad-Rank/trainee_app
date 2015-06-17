class MnmSubjectsController < ApplicationController

  def add_comment
    @cmnt = MnmSubjectComment.new(params[:mnm_subject_comment])
    @cmnt.author = current_user
    @current_user = current_user
    @cmnt.is_approved =true if @current_user.employee? and @emp_dept.name == "Teaching" or @current_user.admin?
    @config = Configuration.find_by_config_key('EnableMnmSubjectModeration')
    @cmnt.save
  end

  def upload_document
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id)
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "Teaching" or @current_user.admin?
      @subject = Subject.find(params[:id])
      @subject_docs = @subject.mnm_subject_documents unless @subject.nil?
    else
      redirect_to :action => :index
    end
  end

  def subject_document
    @document = MnmSubjectDocument.new(params[:mnm_subject_document])
    @document.author = current_user
    if @document.save
      redirect_to :action => :upload_document, :id => @document.subject_id
    else
      flash[:notice] = "Document Size should be less than 50 MB and Pdf, Jpeg and Mp4 Types"
      redirect_to :action => :upload_document, :id => @document.subject_id
    end
  end

  def delete_comment
    @comment = MnmSubjectComment.find(params[:id])
    @comment.destroy
  end

  def destroy
    @document = MnmSubjectDocument.find(params[:id])
    @subject = Subject.find(params[:subject_id])
    if @document.destroy
      redirect_to :action => :upload_document, :id => @subject.id
    end
  end

  def index
    @batches = Batch.active
  end

  def show_comment
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    if @current_user.employee? and @emp_dept.name == "Teaching" or @current_user.admin?
      @shared_subject = MnmSharedSubject.find_by_id(params[:id])
      if @shared_subject.nil?
        @subject = Subject.find_by_id(params[:id])
        @comments = @subject.mnm_subject_comments
      else
        @comments = @shared_subject.mnm_subject_comments
      end
      respond_to do |format|
        format.js { render :action => 'show_comment' }
      end
    else
      redirect_to :action => :index
    end
  end


  def show
    @mnm_association = MnmSharedSubjectAssociation.find_by_batch_id(params[:batch_id])
    if params[:batch_id] == ''
      @subjects = []
      @elective_groups = []
    else
      @batch = Batch.find params[:batch_id]
      @subjects = @batch.normal_batch_subject
      @elective_groups = ElectiveGroup.find_all_by_batch_id(params[:batch_id], :conditions =>{:is_deleted=>false})
    end
    respond_to do |format|
      format.js { render :action => 'show' }
    end
  end

  def download_attachment
    #download the  attached file
    @document =MnmSubjectDocument.find params[:id]
    unless @document.nil?
      if @document.download_allowed_for(current_user)
        send_file  @document.document.path , :type=>@document.document_content_type
      else
        flash[:notice] = "#{t('you_are_not_allowed_to_download_that_file')}"
        redirect_to :action => :upload_document, :id => @document.subject_id
      end
    else
      flash[:notice]=t('flash_msg4')
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end

end

