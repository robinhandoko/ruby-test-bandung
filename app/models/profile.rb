class Profile < ActiveRecord::Base
  BACKUP_TYPE_FOLDER = "1"
  BACKUP_TYPE_FILE = "2"

  has_many :backup_files

  validates :name, :exclude_path, :include_path, presence: true

  def get_executeable_path
    execute_path = []

    include_path.split(",").each do |path|
      Dir["#{path}/**/*"].each do |stuff|
        exclude_path.split(",").each do |exclude|
          next if stuff.match("#{exclude}")
          execute_path << stuff
        end
      end
    end

    execute_path.uniq
  end

  def build_hash
    path_file = []
    include_path.split(",").each do |path|
      Dir.foreach(path) do |entry|
         path_file << entry
      end
    end

     path_file
  end

  def execute_backup
    profile = self
    execute_path = profile.get_executeable_path

    if execute_path.present?
      tmp_path = ""
      tmp_parent_id = nil
      total_storage = 0

      ActiveRecord::Base.transaction do
        profile.backup_files.where(is_current_version: true).update_all(is_current_version: false)

        execute_path.each do |stuff|
          info_stuff = File.stat(stuff)
          size = info_stuff.size
          permission_stuff = info_stuff.world_readable?
          access_number = sprintf("%o", permission_stuff)
          group_id = info_stuff.gid
          user_id = info_stuff.uid
          array_path = stuff.split("/")

          backup_file = profile.backup_files.new

          if File.directory?(stuff)
            backup_file.backup_type = BACKUP_TYPE_FOLDER
            backup_file.folder_name = array_path.last

            if tmp_path == array_path[0..array_path.length-2]
              backup_file.parent_id = tmp_parent_id
            end

            tmp_path = array_path
          end

          if File.file?(stuff)
            md5sum = Digest::MD5.file(stuff).to_s

            backup_file.backup_type = BACKUP_TYPE_FILE
            backup_file.md5 = md5sum

            if tmp_path == array_path[0..array_path.length-2]
              backup_file.parent_id = tmp_parent_id
            end

            File.open(stuff) do |f|
              backup_file.file_name = f
            end
          end

          backup_file.access_number      = access_number
          backup_file.file_size          = size
          backup_file.gid                = group_id
          backup_file.uid                = user_id
          backup_file.last_modified_time = info_stuff.mtime
          backup_file.save!

          total_storage += size

          tmp_parent_id = backup_file.id if backup_file.backup_type == BACKUP_TYPE_FOLDER
        end

        profile.last_backup = Time.zone.now
        profile.storage = total_storage
        profile.save!
      end
    end
  end
end
