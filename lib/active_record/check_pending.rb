# frozen_string_literal: true

module ActiveRecord
  class Migration
    class CheckPending
      def initialize(app)
        @app = app
        @last_check = 0
      end

      def call(env)
        mtime = connection.migration_context.last_migration.mtime.to_i
        if @last_check < mtime
          ActiveRecord::Tasks::DatabaseTasks.migrate if needs_migration?
          @last_check = mtime
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
    end
  end
end
