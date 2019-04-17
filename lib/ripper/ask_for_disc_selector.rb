# frozen_string_literal: true

class AskForDiscSelector
  attr_accessor :selected_disc

  class << self
    def perform
      disc_selector = AskForDiscSelector.new
      disc_selector.wait_for_discs_to_be_present
      while Config.configuration.selected_disc_info.nil?
        discs = DiscInfo.list_discs
        next if discs.nil? || discs.empty?

        disc_selector.select_only_disk_avalable(discs)
        disc_selector.ask_user_which_disk(discs)
        Config.configuration.selected_disc_info = disc_selector.selected_disc
      end
    end
  end

  def wait_for_discs_to_be_present
    Shell.show_wait_spinner('Could not find any disc currently inserted. Please insert a disc.') do
      DiscInfo.list_discs.empty?
    end
  end

  def select_only_disk_avalable(discs)
    return if discs.size != 1

    self.selected_disc = discs.first
  end

  def ask_user_which_disk(discs)


    while selected_disc.nil?
      self.selected_disc = TTY::Prompt.new.select(
        'There where multiple discs found which one do you want to use'
      ) do |menu|
        discs.each do |disc|
          menu.choice disc.describe, disc
        end
      end
    end
  end
end
