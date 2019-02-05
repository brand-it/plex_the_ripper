class MakeBackup
  def initialize
  end

  def perform
  end

  private

  def backup_disk
    while running
      if Config.configuration.selected_disc_info
        Config.configuration.selected_disc_info.reload
      end
      which_disc?
    end
  end

end