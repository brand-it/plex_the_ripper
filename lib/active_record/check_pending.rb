# frozen_string_literal: true

module ActiveRecord
  class Migration
    class CheckPending
      def initialize(app, file_watcher: ActiveSupport::FileUpdateChecker)
        @app = app
        @needs_check = true
        @mutex = Mutex.new
        @file_watcher = file_watcher
      end

      def call(env) # rubocop:disable Metrics/MethodLength
        @mutex.synchronize do
          @watcher ||= build_watcher do
            @needs_check = true
            ActiveRecord::Tasks::DatabaseTasks.migrate if needs_migration?
            @needs_check = false
          end

          if @needs_check
            @watcher.execute
          else
            @watcher.execute_if_updated
          end
        end
        @app.call(env)
      end

      private

      def needs_migration?
        connection.migration_context.needs_migration?
      end

      def connection
        ActiveRecord::Base.connection
      end

      def build_watcher(&block)
        paths = Array(connection.migration_context.migrations_paths)
        @file_watcher.new([], paths.index_with(['rb']), &block)
      end
    end
  end
end
