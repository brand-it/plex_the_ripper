module MkvMaker
  class Version < Base
    extend Dry::Initializer

    HOST = 'www.makemkv.com'

    # Note: I could use nokogiri to parse this html however the time to install the gem
    # along with just the over kill of what I need this was just not worth it.
    # Time to use simple string match :D
    #
    # There is a down side to this code. It does not take into account many version numbers
    def results
      @results ||= get.body.scan(/MakeMKV (\d*\.\d*\.\d*)/).flatten.uniq.first
    end

    private

    def path
      '/download/'
    end
  end
end
