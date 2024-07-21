# frozen_string_literal: true

class ChecksumService < ApplicationService
  CHUNK_SIZE = 5.megabytes

  option :io, Types.Interface(:read)
  option :progress_listener, Types.Interface(:call), optional: true

  def call
    compute_checksum_in_chunks(io)
  end

  private

  def compute_checksum_in_chunks(io)
    Digest::MD5.new.tap do |checksum|
      while chunk = io.read(CHUNK_SIZE) # rubocop:disable Lint/AssignmentInCondition
        Rails.logger.debug { "Checking chunck: #{chunk.size}" }
        progress_listener&.call(chunk_size: chunk.size)
        checksum << chunk
      end

      io.rewind
    end.base64digest
  end
end
