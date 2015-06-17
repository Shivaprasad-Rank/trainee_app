menu_link_present = MenuLink rescue false
unless menu_link_present == false
  academics_category = MenuLinkCategory.find_by_name("academics")

  MenuLink.create(:name=>'mnm_subjects',:target_controller=>'mnm_subjects',:target_action=>'index',:higher_link_id=>nil,:icon_class=>'google-docs-icon',:link_type=>'general',:user_type=>nil,:menu_link_category_id=>academics_category.id) unless MenuLink.exists?(:name=>'mnm_subjects')
  higher_link=MenuLink.find_by_name_and_higher_link_id('mnm_subjects',nil)

  MenuLink.create(:name=>'manage_shared_subjects',:target_controller=>'mnm_shared_subjects',:target_action=>'index',:higher_link_id=>higher_link.id,:icon_class=>nil,:link_type=>'general',:user_type=>nil,:menu_link_category_id=>academics_category.id) unless MenuLink.exists?(:name=>'manage_shared_subjects')
  MenuLink.create(:name=>'manage_class_lists',:target_controller=>'mnm_class_lists',:target_action=>'index',:higher_link_id=>higher_link.id,:icon_class=>nil,:link_type=>'general',:user_type=>nil,:menu_link_category_id=>academics_category.id) unless MenuLink.exists?(:name=>'manage_class_lists')
end