namespace :mkv  do
  desc 'Install MKV'
  task install: :environment do
    puts 'MKV Installing'.blue
    if OS.mac?
      MkvInstaller::MacOs.call
      puts 'MKV Installed'.green
    elsif OS.posix?
      MkvInstaller::Posix.call
      puts 'MKV Installed'.green
    else
      puts "I have no idea how to install MKV for #{OS.host_os}".yellow
      puts 'You should be able to install it manually from this url'.yellow
      puts MkvInstaller::Base::DOWNLOAD_URI.to_s.yellow
    end
  end
end
