class JobsBase
  include Concurrent::Async
  class << self
    attr_accessor :process

    def perform(*args)
      return unless ready?

      new(*args).tap do |job|
        self.process = job.async.call
      end
    end

    def ready?
      process.nil? || fulfilled?
    end

    def fulfilled?
      !!process&.fulfilled?
    end

    def pending?
      !!process&.pending?
    end
  end
end
