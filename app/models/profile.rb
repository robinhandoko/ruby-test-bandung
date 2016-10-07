class Profile < ActiveRecord::Base
  BACKUP_TYPE_FOLDER = "1"
  BACKUP_TYPE_FILE = "2"

  has_many :backup_files

  validates :name, :include_path, presence: true

  def self.construct_execute_hash(path, tmp_hash, exclude_path)
    Dir.foreach(path) do |fname|
      next if fname[0] == "."

      x = path + "/#{fname}"
      next if x.match("#{exclude_path}")

      if File.directory?(x)
        tmp_hash[fname] = { files: []}
        selected_hash = tmp_hash[fname]
        Profile.construct_execute_hash(x, selected_hash, exclude_path)
      else
        tmp_hash[:files] << fname
      end
    end

    tmp_hash
  end

  def self.iterate_content(execute_hash, path, profile)
    execute_hash.each do |key, value|
      next if key == :parent_id

      if key == :files
        next if value.blank?

        file_path = path + "/#{value[0]}"
        profile.store_file(file_path, execute_hash[:parent_id])
      else
        folder_path = path + "/#{key}"
        backup = profile.store_folder(folder_path, execute_hash[:parent_id])
        execute_hash[key].merge!({ parent_id: backup.id })

        Profile.iterate_content(execute_hash[key], folder_path, profile)
      end
    end
  end

  def get_executeable_path
    tmp_hash = []

    include_path.split(",").each do |path|
      if File.directory?(path)
        tmp_hash << { path: path, content: Profile.construct_execute_hash(path, {files: []}, exclude_path)}
      else
        next if path.match("#{exclude_path}")
        tmp_hash << { path: path, content: []}
      end
    end

    tmp_hash
  end

  def store_folder(folder_path, parent_id = nil)
    folder_name = folder_path.split("/")[-1]

    store_parameter = {
      folder_name: folder_name,
      parent_id: parent_id,
      backup_type: BACKUP_TYPE_FOLDER
    }.merge!(BackupFile.get_file_info(folder_path))

    backup = backup_files.create!(store_parameter)
    backup
  end

  def store_file(file_path, parent_id)
    store_parameter = {
      parent_id: parent_id,
      backup_type: BACKUP_TYPE_FILE
    }.merge!(BackupFile.get_file_info(file_path))

    backup = backup_files.new(store_parameter)

    File.open(file_path) do |f|
      backup.file_name = f
    end

    backup.save!
    backup
  end

  def execute_backup
    backup_files.update_all(is_current_version: false)

    get_executeable_path.each do |execute_hash|
      current_path = execute_hash[:path]

      if File.directory?(current_path)
        backup = store_folder(current_path, nil)
      end

      if File.file?(current_path)
        backup = store_file(current_path, nil)
      end

      parent_id = backup.id

      if execute_hash[:content].present?
        execute_hash[:content][:files].each do |file_name|
          file_path = current_path + "/#{file_name}"
          store_file(file_path, parent_id)
        end

        execute_hash[:content].keys.each do |parent_folder_name|
          next if parent_folder_name == :files

          parent_path = current_path + "/#{parent_folder_name}"
          parent_backup = store_folder(parent_path, parent_id)
          execute_hash[:content][parent_folder_name].merge!({parent_id: parent_backup.id})
          Profile.iterate_content(execute_hash[:content][parent_folder_name], parent_path, self)
        end
      end
    end

    update_attributes(storage: backup_files.active.sum(:file_size))
  end
end
