# frozen_string_literal: true

class ChecksumService
  extend Dry::Initializer

  option :io, Types.Interface(:read)

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def call
    compute_checksum_in_chunks(io)
  end

  private

  def compute_checksum_in_chunks(io)
    Digest::MD5.new.tap do |checksum|
      while chunk = io.read(5.megabytes) # rubocop:disable Lint/AssignmentInCondition
        Rails.logger.debug { "Checking chunck: #{chunk.size}" }
        checksum << chunk
      end

      io.rewind
    end.base64digest
  end
end
