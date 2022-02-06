# frozen_string_literal: true

namespace :mkv  do
  desc 'Install MKV'
  task install: :environment do
    puts Rainbow('MKV Installing').blue
    if OS.mac?
      MkvInstaller::MacOs.call
      puts Rainbow('MKV Installed').green
    elsif OS.posix?
      MkvInstaller::Posix.call
      puts Rainbow('MKV Installed').green

    else
      puts Rainbow("I have no idea how to install MKV for #{OS.host_os}").yellow
      puts Rainbow('You should be able to install it manually from this url').yellow
      puts Rainbow(MkvInstaller::Base::DOWNLOAD_URI.to_s).yellow
    end
  end
end
