# desc "Explaining what the task does"
# task :mnminstitute_subject_timetable_customisation do
#   # Task goes here
# end
namespace :mnminstitute_subject_timetable_customisation do
  desc "Install Mnminstitute Subject Timetable Customisation Module"
  task :install do
    system "rsync --exclude=.svn -ruv vendor/plugins/mnminstitute_subject_timetable_customisation/public ."
    system "rsync -ruv --exclude=.svn vendor/plugins/mnminstitute_subject_timetable_customisation/db/migrate db"
  end
end