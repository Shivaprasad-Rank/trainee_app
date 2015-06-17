class MnmSharedTimetableEntriesController < ApplicationController

  def update_shared_timetable_entries2
    @timetable=Timetable.find(params[:timetable_id])
    employees_subject = EmployeesSubject.find_all_by_id(params[:emp_sub_id].split(',').sort).first
    sub_ids=params[:emp_sub_id].split(",")
    emp_ids=EmployeesSubject.find_all_by_id(sub_ids).collect(&:employee_id)
    tte_ids = params[:tte_ids].split(",").each {|x| x}
    @batch = employees_subject.subject.batch
    timetable_class_timings = TimeTableClassTiming.find_by_batch_id_and_timetable_id(@batch.id,@timetable.id).class_timing_set.class_timings.map(&:id)
    subject = employees_subject.subject
    employee = employees_subject.employee
    emp_s=employee.subjects.collect(&:elective_group_id).compact
    @validation_problems = {}
    tte_ids.each do |tte_id|
      co_ordinate=tte_id.split("_")
      weekday=co_ordinate[0].to_i
      class_timing=co_ordinate[1].to_i
      #raise class_timing.to_s
      overlap= TimetableEntry.find(:all,:conditions=>{:employee_id=>emp_ids,:timetable_id=>@timetable.id,:class_timing_id=>class_timing,:weekday_id=>weekday},:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0")
      unless overlap.empty?
        tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
        errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> overlap[0].employee_id,"tte_id" => tte_id},
          "messages" => [] }
        @overlap = overlap
        overlap.each do |overlap|
          errors["messages"] << "#{t('class_overlap')}: #{overlap.batch.full_name}."
        end
      else
        tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
        errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
          "messages" => [] }
      end
      if errors.empty?
        unless emp_s.empty?
          emp_subs=Subject.find_all_by_elective_group_id(emp_s).collect(&:id)
          overlap_elective=TimetableEntry.find(:all,:conditions=>{:subject_id=>emp_subs,:timetable_id=>@timetable.id,:class_timing_id=>class_timing,:weekday_id=>weekday},:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0")
          unless overlap_elective.empty?
            overlap_elective.each do |overlap|
              errors["messages"] << "#{t('class_overlap')} #{overlap.batch.full_name}"
            end

          end
        end
      end

      errors["messages"] << "#{t('weekly_limit_reached')}" \
        if subject.max_weekly_classes <= TimetableEntry.find(:all,:conditions =>{:subject_id=>subject.id,:timetable_id=>@timetable.id, :class_timing_id => timetable_class_timings}).count unless subject.max_weekly_classes.nil?

      employee = subject.lower_day_grade unless subject.elective_group_id.nil?
      errors["messages"] << "#{t('max_hour_exceeded_day')}" \
        if employee.max_hours_per_day <= TimetableEntry.find(:all,:conditions => "timetable_entries.timetable_id=#{@timetable.id} AND timetable_entries.employee_id = #{employee.id} AND weekday_id = #{weekday}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0").select{|tt| timetable_class_timings.include? tt.class_timing_id}.count unless employee.max_hours_per_day.nil?

      # check for max hours per week
      employee = subject.lower_week_grade unless subject.elective_group_id.nil?
      errors["messages"] << "#{t('max_hour_exceeded_week')}" \
        if employee.max_hours_per_week <= TimetableEntry.find(:all,:conditions => "timetable_entries.timetable_id=#{@timetable.id} AND timetable_entries.employee_id = #{employee.id}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0").select{|tt| timetable_class_timings.include? tt.class_timing_id}.count unless employee.max_hours_per_week.nil?

      if errors["messages"].empty?

        if MnmSharedSubjectAssociation.exists?(:subject_id => subject.id)
          @mnm_association = MnmSharedSubjectAssociation.find_by_subject_id(subject.id)
          @mnm_associations = MnmSharedSubjectAssociation.find_all_by_mnm_shared_subject_id(@mnm_association.mnm_shared_subject_id)
          @batches = []
          @mnm_associations.each do |mnm_association|
            @new_batch = Batch.find_by_id(mnm_association.batch_id)
            if !@batch.nil?
              @batches << @new_batch
            end
          end
          @batches.each do |batch|
            if batch.id == @batch.id
              tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
              errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
                "messages" => [] }
              unless tte.nil?
                TimetableEntry.update(tte.id, :subject_id => subject.id, :employee_id=>employee.id,:timetable_id=>@timetable.id)
                AllocatedClassroom.destroy_all("timetable_entry_id = #{tte.id}")

                @mnm_timetable_association = MnmSharedTimetableAssociation.find_by_timetable_entry_id(tte.id)
                @mnm_timetable_association.update_attributes(:subject_id => subject.id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id) unless @mnm_timetable_association.nil?

                @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(subject.id, employees_subject.employee_id )
                if @emp_sub_association.nil?
                  EmployeesSubject.new(:subject_id => subject.id,  :employee_id => employees_subject.employee_id).save
                end
              else
                @new_tte = TimetableEntry.new
                @new_tte = TimetableEntry.create(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => subject.id, :employee_id=>employee.id,:batch_id=>batch.id,:timetable_id=>@timetable.id)
                MnmSharedTimetableAssociation.create(:subject_id => subject.id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id, :timetable_id => @timetable.id, :timetable_entry_id => @new_tte.id )

                @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(subject.id, employees_subject.employee_id )
                if @emp_sub_association.nil?
                  EmployeesSubject.new(:subject_id => subject.id,  :employee_id => employees_subject.employee_id).save
                end
              end
            else
              @shared_association = MnmSharedSubjectAssociation.find_by_mnm_shared_subject_id_and_batch_id(@mnm_association.mnm_shared_subject_id,batch.id )
              #              @batch_weekday = Weekday.find(weekday)
              
              #              puts "BBBBBBBBBBBBBBBBBB#{@batch_weekday.inspect}"
              #              @weekday = Weekday.find_by_batch_id_and_day_of_week(batch.id,@batch_weekday.day_of_week)
              
              #              @batch_class_timing = ClassTiming.find(class_timing)
              #              puts "*******batch class_timing *****#{@batch_class_timing.inspect}"
              #              @class_timing = ClassTiming.find_by_batch_id_and_start_time_and_end_time(batch.id, @batch_class_timing.start_time, @batch_class_timing.end_time )
              #             puts "!!!!!!!!!!!!!!!!!!!!!!class_timing #{@class_timing.inspect}"
              tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,batch.id,@timetable.id)
              
              errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
                "messages" => [] }
              unless tte.nil?
                TimetableEntry.update(tte.id, :subject_id => @shared_association.subject_id, :employee_id=>employee.id,:timetable_id=>@timetable.id)

                AllocatedClassroom.destroy_all("timetable_entry_id = #{tte.id}")
                @mnm_timetable_association = MnmSharedTimetableAssociation.find_by_timetable_entry_id(tte.id)
                @mnm_timetable_association.update_attributes(:subject_id => @shared_association.subject_id, :mnm_shared_subject_id =>@shared_association.mnm_shared_subject_id ) unless @mnm_timetable_association.nil?

                @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(@shared_association.subject_id, employees_subject.employee_id )
                if @emp_sub_association.nil?
                  EmployeesSubject.new(:subject_id => @shared_association.subject_id,  :employee_id => employees_subject.employee_id).save
                end
              else
                @new_tte = TimetableEntry.new
                @new_tte = TimetableEntry.create(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => @shared_association.subject_id, :employee_id=>employee.id,:batch_id=>batch.id,:timetable_id=>@timetable.id)
                MnmSharedTimetableAssociation.create(:subject_id => @shared_association.subject_id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id, :timetable_id => @timetable.id, :timetable_entry_id => @new_tte.id )

                @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(@shared_association.subject_id, employees_subject.employee_id )
                if @emp_sub_association.nil?
                  EmployeesSubject.new(:subject_id => @shared_association.subject_id,  :employee_id => employees_subject.employee_id).save
                end
              end
            end
          end
        else
          unless tte.nil?
            TimetableEntry.update(tte.id, :subject_id => subject.id, :employee_id=>employee.id,:timetable_id=>@timetable.id)
            AllocatedClassroom.destroy_all("timetable_entry_id = #{tte.id}")
          else
            TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => subject.id, :employee_id=>employee.id,:batch_id=>@batch.id,:timetable_id=>@timetable.id).save
          end
        end

      else
        @validation_problems[tte_id] = errors
      end
    end
    tte_from_batch_and_tt(@timetable.id)
    render :partial => "timetable_entries/new_entry"
  end


  def shared_tt_entry_update2
    @errors = {"messages" => []}
    @timetable=Timetable.find(params[:timetable_id])
    @batch=Batch.find(params[:batch_id])
    subject = Subject.find(params[:sub_id])
    co_ordinate=params[:tte_id].split("_")
    weekday=co_ordinate[0].to_i
    class_timing=co_ordinate[1].to_i
    #      tte = TimetableEntry.find(tte_id)
    tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
    overlapped_tte = TimetableEntry.find_all_by_weekday_id_and_class_timing_id_and_employee_id_and_timetable_id(weekday,class_timing,params[:emp_id],@timetable.id)

    if MnmSharedSubjectAssociation.exists?(:subject_id => subject.id)
      @mnm_association = MnmSharedSubjectAssociation.find_by_subject_id(subject.id)
      @mnm_associations = MnmSharedSubjectAssociation.find_all_by_mnm_shared_subject_id(@mnm_association.mnm_shared_subject_id)
      @batches = []
      @mnm_associations.each do |mnm_association|
        @new_batch = Batch.find_by_id(mnm_association.batch_id)
        if !@batch.nil?
          @batches << @new_batch
        end
      end
      @batches.each do |batch|
        if batch.id == @batch.id
          tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
          overlapped_tte = TimetableEntry.find_all_by_weekday_id_and_class_timing_id_and_employee_id_and_timetable_id(weekday,class_timing,params[:emp_id],@timetable.id)

          if overlapped_tte.nil?
            unless tte.nil?
              TimetableEntry.update(tte.id, :subject_id => params[:sub_id], :employee_id => params[:emp_id])

              @mnm_timetable_association = MnmSharedTimetableAssociation.find_by_timetable_entry_id(tte.id)
              @mnm_timetable_association.update_attributes(:subject_id => params[:sub_id], :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id) unless @mnm_timetable_association.nil?

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(params[:sub_id], params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => params[:sub_id],  :employee_id => params[:emp_id]).save
              end

            else
              TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => params[:sub_id], :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save

              MnmSharedTimetableAssociation.create(:subject_id => params[:sub_id], :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id, :timetable_id => @timetable.id, :timetable_entry_id => @new_tte.id )

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(params[:sub_id], params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => params[:sub_id],  :employee_id => params[:emp_id]).save
              end
            end
          else
            overlapped_tte.each {|d| d.destroy } if params[:overwrite].present?
            unless tte.nil?
              TimetableEntry.update(tte.id, :subject_id => params[:sub_id], :employee_id => params[:emp_id])

              @mnm_timetable_association = MnmSharedTimetableAssociation.find_by_timetable_entry_id(tte.id)
              @mnm_timetable_association.update_attributes(:subject_id => params[:sub_id], :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id) unless @mnm_timetable_association.nil?

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(params[:sub_id], params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => params[:sub_id],  :employee_id => params[:emp_id]).save
              end

            else
              TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => params[:sub_id], :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save

              MnmSharedTimetableAssociation.create(:subject_id => params[:sub_id], :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id, :timetable_id => @timetable.id, :timetable_entry_id => @new_tte.id )

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(params[:sub_id], params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => params[:sub_id],  :employee_id => params[:emp_id]).save
              end
            end
          end

        else

          @shared_association = MnmSharedSubjectAssociation.find_by_mnm_shared_subject_id_and_batch_id(@mnm_association.mnm_shared_subject_id,batch.id )
#          @batch_weekday = Weekday.find(weekday)
#          @weekday = Weekday.find_by_batch_id_and_day_of_week(batch.id,@batch_weekday.day_of_week)
#          @batch_class_timing = ClassTiming.find(class_timing)
#          @class_timing = ClassTiming.find_by_batch_id_and_start_time_and_end_time(batch.id, @batch_class_timing.start_time, @batch_class_timing.end_time )
          tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,batch.id,@timetable.id)
          overlapped_tte = TimetableEntry.find_all_by_weekday_id_and_class_timing_id_and_employee_id_and_timetable_id(weekday,class_timing,params[:emp_id],@timetable.id)

          if overlapped_tte.nil?
            unless tte.nil?
              TimetableEntry.update(tte.id, :subject_id => @shared_association.subject_id, :employee_id => params[:emp_id])

              @mnm_timetable_association = MnmSharedTimetableAssociation.find_by_timetable_entry_id(tte.id)
              @mnm_timetable_association.update_attributes(:subject_id => @shared_association.subject_id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id) unless @mnm_timetable_association.nil?

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(@shared_association.subject_id, params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => @shared_association.subject_id,  :employee_id => params[:emp_id]).save
              end

            else
              TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => @shared_association.subject_id, :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save

              MnmSharedTimetableAssociation.create(:subject_id => @shared_association.subject_id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id, :timetable_id => @timetable.id, :timetable_entry_id => @new_tte.id )

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(@shared_association.subject_id, params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => @shared_association.subject_id,  :employee_id => params[:emp_id]).save
              end
            end
          else
            overlapped_tte.each {|d| d.destroy } if params[:overwrite].present?
            unless tte.nil?
              TimetableEntry.update(tte.id, :subject_id => @shared_association.subject_id, :employee_id => params[:emp_id])

              @mnm_timetable_association = MnmSharedTimetableAssociation.find_by_timetable_entry_id(tte.id)
              @mnm_timetable_association.update_attributes(:subject_id => @shared_association.subject_id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id) unless @mnm_timetable_association.nil?

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(@shared_association.subject_id, params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => @shared_association.subject_id,  :employee_id => params[:emp_id]).save
              end

            else
              TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => @shared_association.subject_id, :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save

              MnmSharedTimetableAssociation.create(:subject_id => @shared_association.subject_id, :mnm_shared_subject_id => @mnm_association.mnm_shared_subject_id, :timetable_id => @timetable.id, :timetable_entry_id => @new_tte.id )

              @emp_sub_association = EmployeesSubject.find_by_subject_id_and_employee_id(@shared_association.subject_id, params[:emp_id] )
              if @emp_sub_association.nil?
                EmployeesSubject.new(:subject_id => @shared_association.subject_id,  :employee_id => params[:emp_id]).save
              end
            end
          end

        end
      end
    else
      if overlapped_tte.nil?
        unless tte.nil?
          TimetableEntry.update(tte.id, :subject_id => params[:sub_id], :employee_id => params[:emp_id])
        else
          TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => params[:sub_id], :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save
        end
      else
        overlapped_tte.each {|d| d.destroy } if params[:overwrite].present?
        unless tte.nil?
          TimetableEntry.update(tte.id, :subject_id => params[:sub_id], :employee_id => params[:emp_id])
        else
          TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => params[:sub_id], :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save
        end
        #      TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
      end
    end

    tte_from_batch_and_tt(@timetable.id)
    render :update do |page|
      page.replace_html "box", :partial=> "timetable_entries/timetable_box"
      page.replace_html "subjects-select", :partial=> "timetable_entries/employee_select"
      page.replace_html "error_div_#{params[:tte_id]}", :text => "#{t('done')}"
    end
    #    render :partial => "new_entry"
  end



  private

  def tte_from_batch_and_tt(tt)
    @tt=Timetable.find(tt)
    time_table_class_timings = TimeTableClassTiming.find_by_timetable_id_and_batch_id(@tt.id,@batch.id)
    @class_timing = time_table_class_timings.nil? ? Array.new : time_table_class_timings.class_timing_set.class_timings.timetable_timings
    unless @tt.time_table_weekdays.find_by_batch_id(@batch.id).present?
      @tt.time_table_weekdays.create(:batch_id => @batch.id,:weekday_set_id => @batch.weekday_set_id.nil? ? WeekdaySet.first.id : @batch.weekday_set_id)
    end
    @weekday = @tt.time_table_weekdays.find_by_batch_id(@batch.id).weekday_set.weekday_ids
    timetable_entries=TimetableEntry.find(:all,:conditions=>{:batch_id=>@batch.id,:timetable_id=>@tt.id},:include=>[:subject,:employee])
    @timetable= Hash.new { |h, k| h[k] = Hash.new(&h.default_proc)}
    timetable_entries.each do |tte|
      @timetable[tte.weekday_id][tte.class_timing_id]=tte
    end
    @subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NULL AND is_deleted = false"])
    @ele_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"], :group => "elective_group_id")
  end

end

