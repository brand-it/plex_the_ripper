# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
# max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
# min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads 1, 2

workers 0 # Won't work on multiple process because it shares memory for webhooks

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port        ENV.fetch('PORT', 3000)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# Allow puma to be restarted by `rails restart` command.
# plugin :tmp_restart

# after boot kick off background jobs
# rubocop:disable Metrics/BlockLength, Rails/Output
on_booted do
  Backgrounder.start if ENV.fetch('BACKGROUNDER', 'true') == 'true'
  rack_port = ARGV.index('-p') ? ARGV[ARGV.index('-p').next].to_i : 3000
  rack_port = ENV['PORT'].to_i if rack_port.zero?
  puts <<~STR
           /$$$$$$$  /$$
          | $$__  $$| $$
          | $$   $$| $$  /$$$$$$  /$$   /$$
          | $$$$$$$/| $$ /$$__  $$|  $$ /$$/
          | $$____/ | $$| $$$$$$$$   $$$$/
          | $$      | $$| $$_____/  >$$  $$
          | $$      | $$|  $$$$$$$ /$$/  $$
          |__/      |__/ _______/|__/  __/

                   /$$     /$$
                  | $$    | $$
                 /$$$$$$  | $$$$$$$   /$$$$$$
                |_  $$_/  | $$__  $$ /$$__  $$
                  | $$    | $$   $$| $$$$$$$$
                  | $$ /$$| $$  | $$| $$_____/
                  |  $$$$/| $$  | $$|  $$$$$$$
                   ___/  |__/  |__/ _______/

     /$$$$$$$  /$$
    | $$__  $$|__/
    | $$   $$ /$$  /$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$
    | $$$$$$$/| $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$
    | $$__  $$| $$| $$   $$| $$   $$| $$$$$$$$| $$  __/
    | $$   $$| $$| $$  | $$| $$  | $$| $$_____/| $$
    | $$  | $$| $$| $$$$$$$/| $$$$$$$/|  $$$$$$$| $$
    |__/  |__/|__/| $$____/ | $$____/  _______/|__/
                  | $$      | $$
                  | $$      | $$
                  |__/      |__/
          Welcome to start ripping movies & TV shows visit http://localhost:#{rack_port}
  STR
end

on_stopped do
  Backgrounder.shutdown
end
# rubocop:enable Metrics/BlockLength, Rails/Output
