class AddcolumnsToUsers < ActiveRecord::Migration
  def change
  change_table :users do |t|
      t.string :provider, :default => "", :null => false
      t.string :uid, :default => "", :null => false
     end
  end
end
