class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :prepare_profile, only: [:destroy, :run_backup, :show, :browse]

  def index
    @profiles = current_user.profiles
  end

  def new
    @profile = current_user.profiles.new
  end

  def show
  end

  def create
    @profile = current_user.profiles.new(profile_params)

    if @profile.save
      flash[:notice] = "Profile saved"
      redirect_to profiles_path
    else
      render action: "new"
    end
  end

  def destroy
    if @profile.destroy
      flash[:notice] = "Profile Removed"
    else
      flash[:error] = "Failed to remote profile"
    end

    redirect_to profiles_path
  end

  def run_backup
    @profile.execute_backup

    redirect_to profiles_path, notice: "Backup executed."
  end

  def browse
    @backup_files = @profile.backup_files.where(parent_id: nil, is_current_version: true).order("backup_type, folder_name")
  end

  def show_detail
    @parent_folder =  BackupFile.find_by_id(params[:id])
    @backup_files = BackupFile.where(parent_id: params[:id])

    render template: "profiles/browse"
  end

  private

  def prepare_profile
    @profile = current_user.profiles.find_by_id(params[:id])
    if @profile.blank?
      redirect_to profiles_path, notice: "You are not authorize to access that page"
    end
  end

  def profile_params
    params.require(:profile).permit(:name, :include_path, :exclude_path)
  end
end
