class LoadDiskJob
  include Concurrent::Async

  def load
    Rails.logger.info("load")
    DiskInfoService.new.call
  end

  def broadcast
    load
    Rails.logger.info("ActionCable.server.broadcast")
    ActionCable.server.broadcast('disk', message: 'nice')
  end
end
