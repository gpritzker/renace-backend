class AddApprovedToCapsules < ActiveRecord::Migration[7.1]
  def change
    add_column :capsules, :approved, :boolean, default: false, null: false
  end
end
