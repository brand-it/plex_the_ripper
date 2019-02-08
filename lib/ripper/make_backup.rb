class MakeBackup
  def initialize; end

  def perform; end

  private

  def backup_disk
    while running
      Config.configuration.selected_disc_info.reload if Config.configuration.selected_disc_info
      which_disc?
    end
  end
end
