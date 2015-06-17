
module MnminstituteSubjectTimetableCustomisation
  module MnmApplicantsController


    def self.included (base)
      base.instance_eval do
        alias_method_chain :new, :tmpl
        alias_method_chain :show_pin_entry_form, :tmpl
        alias_method_chain :create , :tmpl
        alias_method_chain :show_form, :tmpl
        alias_method_chain :edit, :tmpl
      end
    end
    
    def new_with_tmpl
      new_without_tmpl
      render :template => "mnm_applicants/new_with_tmpl"
    end

    def show_pin_entry_form_with_tmpl
      if request.xhr?
      render :update do |page|
        @course = RegistrationCourse.find(params[:course_id])
        unless @course.nil?
          if !course_pin_system_registered_for_course(@course.course_id)
            page.replace_html 'pin_entry_form',:partial => 'pin_entry_form'
            page.replace_html 'form',:text => ''
          else
            @countries = Country.all
            @applicant = Applicant.new
            @applicant_guardian = @applicant.build_applicant_guardian
            @selected_value = Configuration.default_country
            @applicant.build_applicant_guardian
            @applicant.build_applicant_previous_data
            @applicant.applicant_addl_attachments.build
            @addl_field_groups = ApplicantAddlFieldGroup.find(:all,:conditions=>{:registration_course_id=>params[:course_id],:is_active=>true})
            @subjects = @course.course.batches.map(&:all_elective_subjects).flatten.compact.map(&:code).compact.flatten.uniq
            @ele_subjects={}
            subject_amounts=@course.course.subject_amounts
            elective_subject_amounts= subject_amounts.find_all_by_code(@subjects)
            @subjects.each do |sub|
              subject=elective_subject_amounts.find_by_code(sub)
              @ele_subjects.merge!(sub=>subject ? subject.amount.to_f: 0 )
            end
            @selected_subject_ids = @applicant.subject_ids.nil? ? [] : @applicant.subject_ids
            additional_mandatory_fields = StudentAdditionalField.active.all(:conditions => {:is_mandatory => true})
            additional_fields = StudentAdditionalField.find_all_by_id(@course.additional_field_ids).compact
            @additional_fields = (additional_mandatory_fields + additional_fields).uniq.compact.flatten
            @applicant_additional_details = @applicant.applicant_additional_details
            @currency = currency
            if @course.subject_based_fee_colletion == true
              normal_subjects=@course.course.batches.map(&:normal_batch_subject).flatten.compact.map(&:code).compact.flatten.uniq
              @normal_subject_amount=subject_amounts.find(:all,:conditions => {:code => normal_subjects}).flatten.compact.map(&:amount).sum
            else
              @normal_subject_amount = @course.amount.to_f
            end
            page.replace_html 'form',:partial => "mnm_applicants/form_with_tmpl"
            page.replace_html 'pin_entry_form',:text => ''
          end
        else
          page.replace_html 'form',:text => ''
          page.replace_html 'pin_entry_form',:text => ''
        end
      end
    else
      flash[:notice] = t('flash_register')
      redirect_to new_applicant_path
    end

    end

    def create_with_tmpl
       if FedenaPlugin.can_access_plugin?("fedena_pay")
        if (PaymentConfiguration.config_value("enabled_fees").present? and PaymentConfiguration.config_value("enabled_fees").include? "Application Registration")
        @active_gateway = PaymentConfiguration.config_value("fedena_gateway")
        if @active_gateway == "Paypal"
          @merchant_id = PaymentConfiguration.config_value("paypal_id")
          @merchant ||= String.new
          @certificate = PaymentConfiguration.config_value("paypal_certificate")
          @certificate ||= String.new
        elsif @active_gateway == "Authorize.net"
          @merchant_id = PaymentConfiguration.config_value("authorize_net_merchant_id")
          @merchant_id ||= String.new
          @certificate = PaymentConfiguration.config_value("authorize_net_transaction_password")
          @certificate ||= String.new
        elsif @active_gateway == "Webpay"
          @merchant_id = PaymentConfiguration.config_value("webpay_merchant_id")
          @merchant_id ||= String.new
          @product_id = PaymentConfiguration.config_value("webpay_product_id")
          @product_id ||= String.new
          @item_id = PaymentConfiguration.config_value("webpay_item_id")
          @item_id ||= String.new
        end
      end
    end
    current_school_name = Configuration.find_by_config_key('InstitutionName').try(:config_value)
    @currency = currency
    @courses = RegistrationCourse.active
    if params[:applicant][:subject_ids].nil?
      params[:applicant][:subject_ids]=[]
    else
      params[:applicant][:subject_ids].each_with_index do |e,i|
        params[:applicant][:subject_ids][i]=(e.split-e.split.last.to_a).join(" ")
      end
    end
    @course = RegistrationCourse.find(params[:applicant][:registration_course_id])
    @pin_number = params[:applicant][:pin_number]
    @applicant = Applicant.new(params[:applicant])
    @subjects = @course.course.batches.map(&:all_elective_subjects).flatten.compact.map(&:code).compact.flatten.uniq
    @ele_subjects={}
    subject_amounts=@course.course.subject_amounts
    elective_subject_amounts= subject_amounts.find_all_by_code(@subjects)
    @subjects.each do |sub|
      subject=elective_subject_amounts.find_by_code(sub)
      @ele_subjects.merge!(sub=>subject ? subject.amount.to_f: 0 )
    end
    @selected_subject_ids = @applicant.subject_ids.nil? ? [] : @applicant.subject_ids
    @applicant_guardian = @applicant.build_applicant_guardian(params[:applicant_guardian])
    @applicant_previous_data = @applicant.build_applicant_previous_data(params[:applicant_previous_data])
    @addl_field_groups = ApplicantAddlFieldGroup.find(:all,:conditions=>{:registration_course_id=>@applicant.registration_course_id,:is_active=>true},\
        :include=>[:applicant_addl_fields=>[:applicant_addl_field_values]])
    additional_mandatory_fields = StudentAdditionalField.active.all(:conditions => {:is_mandatory => true})
    additional_fields = StudentAdditionalField.find_all_by_id(@course.additional_field_ids).compact
    @additional_fields = (additional_mandatory_fields + additional_fields).uniq.compact.flatten
    @applicant_additional_details = @applicant.applicant_additional_details
    @currency = currency
    if @course.subject_based_fee_colletion == true
      normal_subjects=@course.course.batches.map(&:normal_batch_subject).flatten.compact.map(&:code).compact.flatten.uniq
      @applicant.normal_subject_ids=normal_subjects
      if params[:applicant][:subject_ids].present?
        @ele_subject_amount=subject_amounts.find(:all,:conditions => {:code => params[:applicant][:subject_ids]}).flatten.compact.map(&:amount).sum
      else
        @ele_subject_amount=0
      end
      @normal_subject_amount=subject_amounts.find(:all,:conditions => {:code => normal_subjects}).flatten.compact.map(&:amount).sum
      @registration_amount = @normal_subject_amount+@ele_subject_amount
      @applicant.amount = @registration_amount.to_f
    else
      @applicant.amount = @course.amount.to_f
    end

    if @applicant.valid?
      pin_no = PinNumber.find_by_number(@applicant.pin_number)
      unless pin_no.nil?
        unless pin_no.is_registered.present?
          pin_no.update_attributes(:is_registered => true)
        else
          flash[:notice]=t('flash4')
          render :action=>'new' and return
        end
      end
      if @course.include_additional_details == true
        @error=false
        mandatory_fields = StudentAdditionalField.find(:all, :conditions=>{:is_mandatory=>true, :status=>true})
        mandatory_fields.each do|m|
          unless params[:applicant_additional_details][m.id.to_s.to_sym].present?
            @applicant.errors.add_to_base("#{m.name} must contain atleast one selected option.")
            @error=true
          else
            if params[:applicant_additional_details][m.id.to_s.to_sym][:additional_info]==""
              @applicant.errors.add_to_base("#{m.name} cannot be blank.")
              @error=true
            end
          end
        end
        unless @error==true
          if params[:applicant_additional_details].present?
            params[:applicant_additional_details].each_pair do |k, v|
              addl_info = v['additional_info']
              addl_field = StudentAdditionalField.find_by_id(k)
              if addl_field.input_type == "has_many"
                addl_info = addl_info.join(", ")
              end
              addl_detail = @applicant.applicant_additional_details.build(:additional_field_id => k,:additional_info => addl_info)
              addl_detail.valid?
              addl_detail.save if addl_detail.valid?
            end
          end
          @applicant.save
          flash[:notice] = t('flash_success')
          render :template => "applicants/success"
        else
          render "mnm_applicants/show_form_with_tmpl",:course_id => @applicant.registration_course_id
        end
      else
        @applicant.save
        flash[:notice] = t('flash_success')
        render :template => "applicants/success"
      end
    else
      render "mnm_applicants/show_form_with_tmpl",:course_id => @applicant.registration_course_id
    end

    end

    def show_form_with_tmpl
      show_form_without_tmpl
     render :template => "mnm_applicants/show_form_with_tmpl"
    end
   
    def edit_with_tmpl
      edit_with_without_tmpl
      render :template => "mnm_applicants/edit_with_tmpl"
    end

end
end