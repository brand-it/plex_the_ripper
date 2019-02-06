# Install Ruby Gems, use the local path to make it happen
class GemInstaller
  class << self
    def install(lib)
      suppress_output do
        return false if `gem list #{lib}`.include?(lib)

        Logger.info("running 'install #{lib} --no-ri --no-rdoc'")
        Gem::GemRunner.new.run(['install', lib, '--no-ri', '--no-rdoc'])
        Logger.info("failed to 'install #{lib} --no-ri --no-rdoc'")
        false
      end
    rescue Gem::SystemExitException
      Logger.info("Successfully Installed #{lib}")
      true
    end

    def reinstall(lib)
      suppress_output do
        return install(lib) unless `gem list #{lib}`.include?(lib)

        Logger.info("Uninstalling #{lib}")
        Gem::GemRunner.new.run(['uninstall', lib, '-a'])
        Logger.info("Failed to uninstall #{lib}")
        install(lib)
      end
    rescue StandardError => exception
      Logger.error("Failure #{exception.message}")
    end

    def suppress_output
      original_stdout = $stdout.clone
      original_stderr = $stderr.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      yield
    ensure
      $stdout.reopen original_stdout
      $stderr.reopen original_stderr
    end
  end
end
