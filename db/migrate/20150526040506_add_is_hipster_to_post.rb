class AddIsHipsterToPost < ActiveRecord::Migration
  def change
    add_column :posts, :is_hipster, :string
  end
end
