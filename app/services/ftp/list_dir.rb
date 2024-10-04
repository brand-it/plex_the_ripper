# frozen_string_literal: true

module Ftp
  class ListDir < Base
    Result = Struct.new(:message, :dirs, :success?)
    extend Dry::Initializer
    option :username, Types::Coercible::String
    option :password, Types::Coercible::String
    option :host, Types::Coercible::String
    option :query, Types::Coercible::String

    def self.search(...)
      new(...).search
    end

    def search
      directories = ftp.dir("#{query}*").filter_map do |entry|
        match = entry.match(/^(d.*?)\s+\d+\s+\S+\s+\S+\s+\d+\s+\S+\s+\d+\s+\d+:\d+\s+(.*)$/)
        match[2] if match && match[1].start_with?('d')
      end
      Result.new(nil, directories, true)
    rescue StandardError => e
      Result.new(e.message, [], false)
    ensure
      ftp.close
    end

    private

    def ftp_options
      {
        username:,
        password:,
        ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
        read_timeout: 5
      }
    end
  end
end
