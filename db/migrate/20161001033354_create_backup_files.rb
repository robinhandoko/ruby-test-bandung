class CreateBackupFiles < ActiveRecord::Migration
  def change
    create_table :backup_files do |t|
      t.integer    :profile_id
      t.integer    :parent_id
      t.string     :backup_type
      t.integer    :gid
      t.integer    :uid
      t.float      :file_size
      t.integer    :access_number
      t.datetime   :last_modified_time
      t.string     :md5
      t.string     :file_name
      t.string     :folder_name
      t.boolean    :is_current_version, default: true
      t.timestamps null: false
    end

    add_index :backup_files, :profile_id
  end
end
