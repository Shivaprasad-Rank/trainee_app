ActionController::Routing::Routes.draw do |map|
map.resources :rm_grading_systems
map.resources :rm_terms
map.resources :rm_term_remarks
map.resources :rm_evaluation_categories
map.resources :rm_observation_groups
  #map.rm_grading_systems 'rm_grading_systems/index', :controller => 'rm_grading_systems', :action => 'index'
#  map.feed 'design_custom_reports/report/new', :controller => 'design_custom_reports', :action => 'new'
#  map.feed 'design_custom_reports/:id/edit', :controller => 'design_custom_reports', :action => 'edit'
#  map.feed 'design_custom_reports/report/create', :controller => 'design_custom_reports', :action => 'create'
#  map.feed 'design_custom_reports/report/update', :controller => 'design_custom_reports', :action => 'update'
#  map.feed 'design_custom_reports/report/image_list', :controller => 'design_custom_reports', :action => 'image_list'
#  map.feed 'design_custom_reports/:id/image_list', :controller => 'design_custom_reports', :action => 'image_list'
#  map.feed 'design_custom_reports/upload_image', :controller => 'design_custom_reports', :action => 'upload_image'
end