class MnmStudentsController < ApplicationController

  def profile
    @student = Student.find(params[:id])
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    @current_user = current_user
    @address = @student.address_line1.to_s + ' ' + @student.address_line2.to_s
    @additional_fields = StudentAdditionalField.all(:conditions=>"status = true")
    @sms_module = Configuration.available_modules
    @sms_setting = SmsSetting.new
    @previous_data = StudentPreviousData.find_by_student_id(@student.id)
    @immediate_contact = Guardian.find(@student.immediate_contact_id) \
      unless @student.immediate_contact_id.nil? or @student.immediate_contact_id == ''
    @comments = @student.mnm_student_comments
    #    @is_moderator = @current_user.privileges.include?(Privilege.find_by_name('StudentCommentManager')) || @current_user.admin?
    @config = Configuration.find_by_config_key('EnableMnmStudentCommentModeration')
    @student_docs = @student.mnm_student_documents
  end


  def add_comment
    @cmnt = MnmStudentComment.new(params[:mnm_student_comment])
    @cmnt.author = current_user
    @cmnt.is_approved =true if @current_user.privileges.include?(Privilege.find_by_name('StudentCommentManager')) || @current_user.employee? || @current_user.admin?
    @config = Configuration.find_by_config_key('EnableMnmStudentCommentModeration')
    @cmnt.save
  end
  
  def delete_comment
    @comment = MnmStudentComment.find(params[:id])
    @comment.destroy
  end

  def comment_approved
    @comment = MnmStudent.find(params[:id])
    status=@comment.is_approved ? false : true
    @comment.update_attributes(:is_approved=>status)
    render :update do |page|
      page.reload
    end
  end

  def upload_document
    @document = MnmStudentDocument.new(params[:mnm_student_document])
    @document.author = current_user
    if  @document.save
      redirect_to :action => :profile, :id => @document.student_id
    else
      flash[:notice] = "Document Size should be less than 50 MB and Pdf, Jpeg and Doc Types"
      redirect_to :action => :profile, :id => @document.student_id
    end
  end

  def destroy
    @document = MnmStudentDocument.find(params[:id])
    if @document.destroy
      redirect_to :action => :profile, :id => @document.student_id
    end
  end

  def download_attachment
    #download the  attached file
    @document =MnmStudentDocument.find params[:id]
    unless @document.nil?
      if @document.download_allowed_for(current_user)
        send_file  @document.document.path , :type=>@document.document_content_type
      else
        flash[:notice] = "#{t('you_are_not_allowed_to_download_that_file')}"
        redirect_to :action => :profile, :id => @document.student_id
      end
    else
      flash[:notice]=t('flash_msg4')
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end

end
