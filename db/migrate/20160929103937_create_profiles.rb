class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer     :user_id
      t.string      :name
      t.float       :storage,     default: 0
      t.datetime    :last_backup
      t.text        :include_path
      t.text        :exclude_path
      t.timestamps null: false
    end

    add_index :profiles, :user_id
  end
end
