# frozen_string_literal: true

require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

ENV['GEM_HOME'] = File.expand_path('../gems', __dir__).to_s
ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', __dir__).to_s
FileUtils.mkdir_p(ENV['GEM_HOME'])
Gem.clear_paths

# Install Ruby Gems, use the local path to make it happen
class GemInstaller
  class << self
    def install(lib)
      return false if gem_present?(lib)

      Logger.info("running `gem install #{lib}`")
      Gem::GemRunner.new.run(['install', lib])
      Logger.info("failed to 'install #{lib}")
      abort
    rescue Gem::SystemExitException => exception
      if exception.exit_code.zero?
        Logger.info("Successfully Installed #{lib}")
        true
      else
        Logger.info("failed to `gem install #{lib}` #{exception.message} #{exception.inspect}")
        abort
      end
    rescue Gem::InstallError => exception
      Logger.error("failed to `gem install #{lib}` #{exception.message} #{exception.inspect}")
      Logger.info("GEM_HOME: #{ENV['GEM_HOME']}")
    end

    def bundle_install
      install('bundler')
      require 'bundler/friendly_errors'
      Bundler.with_friendly_errors do
        require 'bundler/cli'
        Bundler::CLI.start(["--path=#{ENV['GEM_HOME']}", '--without=test'])
      end
    end

    def reset!
      FileUtils.remove_dir(ENV['GEM_HOME'])
      uninstall('bundler')
    end

    def reinstall(lib)
      uninstall(lib)
      install(lib)
    end

    def uninstall(lib)
      return unless gem_present?(lib)

      Logger.info("Uninstalling #{lib}")
      Gem::GemRunner.new.run(['uninstall', lib, '-a', '--force', '-x'])
      Logger.info("Failed to uninstall #{lib}")
    rescue Gem::SystemExitException => exception
      if exception.exit_code.zero?
        Logger.info("Successfully Uninstalling #{lib}")
        true
      else
        Logger.info("failed to `gem uninstall #{lib}` #{exception.message} #{exception.inspect}")
        abort
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

    def require_gems
      begin
        require 'bundler'
      rescue LoadError
        reset!
        bundle_install
      end
      retried = false
      begin
        Bundler.require
      rescue LoadError, Bundler::GemNotFound
        reset!
        bundle_install
        unless retried
          retried = true
          retry
        end
      end
    end

    private

    def gem_present?(lib)
      gem_details = Gem::Specification.find_by_name(lib)
      return false if gem_details.nil?

      gem_details.gem_dir && File.exist?(gem_details.gem_dir)
    rescue Gem::MissingSpecError, NoMethodError
      false
    end
  end
end
