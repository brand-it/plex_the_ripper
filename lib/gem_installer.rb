module GemInstaller
  require 'rubygems'
  require 'rubygems/gem_runner'
  require 'rubygems/exceptions'

  def install(lib)
    return if `gem list #{lib}`.include?(lib)

    # Logger.info "Installing #{lib}"
    Gem::GemRunner.new.run ['install', lib]
  rescue Gem::SystemExitException
    # Logger.success "Installed #{lib}"
  end
end
