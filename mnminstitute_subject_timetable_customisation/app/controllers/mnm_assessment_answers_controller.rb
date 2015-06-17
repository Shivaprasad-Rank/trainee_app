class MnmAssessmentAnswersController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def show
    @assignment= Assignment.active.find params[:assignment_id]
    @assignment_answer= AssignmentAnswer.find_by_id(params[:id])
    @current_user = current_user
    @employee = Employee.find_by_user_id(current_user.id)
    @emp_dept = EmployeeDepartment.find_by_id(@employee.employee_department_id) unless @employee.nil?
    if @assignment_answer.present?
      unless (@assignment.download_allowed_for(current_user))
        flash[:notice] = "#{t('you_are_not_allowed_to_view_that_page')}"
        redirect_to assignments_path
      end
    else
      flash[:notice] = "#{t('you_are_not_allowed_to_view_that_page')}"
      redirect_to assignments_path
    end
    @assessment = Assignment.find_by_id(params[:assignment_id])
    @comments = @assessment.mnm_assessment_answers
  end

  def delete_comment
    @comment = MnmAssessmentAnswer.find(params[:id])
    @comment.destroy
  end

  def comment_approved
    @comment = MnmAssessmentAnswer.find(params[:id])
    status=@comment.is_approved ? false : true
    @comment.update_attributes(:is_approved=>status)
    render :update do |page|
      page.reload
    end
  end

  def add_comment
    @cmnt = MnmAssessmentAnswer.new(params[:mnm_assessment_answer])
    @cmnt.author = current_user
    @cmnt.is_approved =true if @current_user.privileges.include?(Privilege.find_by_name('MnmAssessmentManager')) || @current_user.employee? || @current_user.admin?
    @config = Configuration.find_by_config_key('EnableMnmAssessmentModeration')
    @cmnt.save
  end


  def new
    @assignment= Assignment.active.find_by_id(params[:assignment_id])
    unless @assignment.nil?
      if @assignment.subject.batch_id==current_user.student_record.batch_id
        @assignment_answer = @assignment.assignment_answers.find_by_student_id(current_user.student_record.id)
        unless @assignment_answer.present?
          @assignment_answer = @assignment.assignment_answers.build
        else
          flash[:notice] = "#{t('already_answered')}"
          redirect_to assignments_path
        end
      else
        flash[:notice]="#{t('flash_msg4')}"
        redirect_to :controller => 'user',:action => 'dashboard'
      end
    else
      flash[:notice]=t('flash_msg4')
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end

  def create
    @assignment= Assignment.active.find_by_id(params[:assignment_id])
    unless @assignment.nil?
      @assignment_answer = @assignment.assignment_answers.build(params[:assignment_answer])
      @assignment_answer.student_id = current_user.student_record.id
      if @assignment_answer.save
        flash[:notice] = "#{t('assignment_submitted')}"
        redirect_to assignments_path
      else
        render :action=>:new
      end
    else
      flash[:notice]=t('flash_msg4')
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end


  def edit
    @assignment_answer= AssignmentAnswer.find params[:id]
    @assignment=@assignment_answer.assignment
    if @assignment_answer.download_allowed_for(current_user)
      unless @assignment_answer.status == "REJECTED"
        flash[:notice] ="#{t('you_cannot_edit_this_assignment')}"
        redirect_to assignments_path
      end
    else
      flash[:notice] ="#{t('you_cannot_edit_this_assignment')}"
      redirect_to assignments_path
    end
  end
  def update
    @assignment = Assignment.active.find params[:assignment_id]
    unless @assignment.nil?
      @assignment_answer= AssignmentAnswer.find params[:id]
      @assignment_answer.status = "0"
      if @assignment_answer.update_attributes(params[:assignment_answer])
        flash[:notice] = "#{t('assignment_successfuly_updated')}"
        redirect_to assignment_assignment_answer_path @assignment,@assignment_answer
      else
        flash[:notice] = "#{t('failed_to_update_assignment')}"
        render :action=>:edit
      end
    else
      flash[:notice]=t('flash_msg4')
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end

end
