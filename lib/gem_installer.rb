require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'
require 'pry'
ENV['GEM_HOME'] = File.expand_path('../gems', __dir__).to_s
ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', __dir__).to_s
FileUtils.mkdir_p(ENV['GEM_HOME'])
Gem.clear_paths

# Install Ruby Gems, use the local path to make it happen
class GemInstaller
  class << self
    def install(lib)
      return false if gem_present?(lib)

      Logger.info("running 'install #{lib}'")
      Gem::GemRunner.new.run(['install', lib])
      Logger.info("failed to 'install #{lib}")
      abort
    rescue Gem::SystemExitException => exception
      if exception.exit_code.zero?
        Logger.info("Successfully Installed #{lib}")
        true
      else
        Logger.info("failed to 'install #{lib}")
        abort
      end
    end

    def bundle_install
      install('bundle')
      require 'bundler/friendly_errors'
      Bundler.with_friendly_errors do
        require 'bundler/cli'
        Bundler::CLI.start(["--path=#{File.expand_path('../gems', __dir__)}"])
      end
    end

    def reinstall(lib)
      return install(lib) unless `gem list #{lib}`.include?(lib)

      Logger.info("Uninstalling #{lib}")
      Gem::GemRunner.new.run(['uninstall', lib, '-a'])
      Logger.info("Failed to uninstall #{lib}")
      install(lib)
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

    private

    def gem_present?(lib)
      !Gem::Specification.find_by_name(lib).nil?
    rescue Gem::MissingSpecError
      false
    end
  end
end
