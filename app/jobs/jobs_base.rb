class JobsBase
  include Concurrent::Async
  class << self
    attr_accessor :process

    def perform(*args)
      return process unless process_ready?

      self.process = new(*args).async.call
    end

    def process_ready?
      process.nil? || process_fulfilled?
    end

    def process_fulfilled?
      !!process&.fulfilled?
    end

    def process_pending?
      !!process&.pending?
    end
  end
end
