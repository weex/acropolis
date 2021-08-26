# frozen_string_literal: true

class ChangeNewUserPostDefaultToPublic < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :post_default_public, :boolean, default: true
  end

  def down
    change_column :users, :post_default_public, :boolean, default: false
  end
end
