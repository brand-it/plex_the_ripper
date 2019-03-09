# frozen_string_literal: true

class MakeBackup
  def initialize; end

  def perform; end

  private

  def backup_disk
    while running
      Config.configuration.selected_disc_info&.reload
      which_disc?
    end
  end
end
