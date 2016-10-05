class BackupFile < ActiveRecord::Base
  belongs_to :profile

  mount_uploader :file_name, FileUploader

  BACKUP_TYPE = {
    "1": "Folder",
    "2": "File"
  }
end
