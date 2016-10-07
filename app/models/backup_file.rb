class BackupFile < ActiveRecord::Base
  belongs_to :profile

  mount_uploader :file_name, FileUploader

  scope :active, -> { where(is_current_version: true) }

  def self.get_file_info(path)
    info_stuff = File.stat(path)
    permission_stuff = info_stuff.world_readable?

    file_info = {
      access_number: sprintf("%o", permission_stuff),
      file_size: info_stuff.size,
      gid: info_stuff.gid,
      uid: info_stuff.uid,
      last_modified_time: info_stuff.mtime
    }

    if File.file?(path)
      file_info.merge!({
        md5: Digest::MD5.file(path).to_s
      })
    end

    file_info
  end
end
