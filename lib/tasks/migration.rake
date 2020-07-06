# frozen_string_literal: true

namespace :migration do
  desc 'Create a new migration'
  task :create, [:file_name] => [:environment] do |_t, args|
    File.open(migration_path(args[:file_name]), 'w') do |file|
      file.write <<~RUBY
        # frozen_string_literal: true
        class #{migration_class(args[:file_name])} < ActiveRecord::Migration[6.0]
          def self.up
          end
          def self.down
          end
        end
      RUBY
    end

    puts "Migration #{migration_path(args[:file_name])} created".colorize(:green)
  end

  def timestamp
    @timestamp ||= Time.now.strftime('%Y%m%d%H%M%S')
  end

  def migration_path(file_name)
    "#{DatabaseTasks.migrations_paths}/#{timestamp}_#{file_name}.rb"
  end

  def migration_class(file_name)
    file_name.split('_').map(&:capitalize).join
  end
end
