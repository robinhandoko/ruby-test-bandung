module ProfilesHelper
  def render_backup_file_name(backup_file)
    case backup_file.backup_type
    when "1"
      link_to backup_file.folder_name, show_detail_profile_path(backup_file.id)
    when "2"
      link_to backup_file.file_name.url.split("/")[-1], "#"
    else
      "-"
    end
  end
end
