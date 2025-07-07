# frozen_string_literal: true

# Get actual CPU allocation for container
def get_container_cpus
  quota = File.read('/sys/fs/cgroup/cpu/cpu.cfs_quota_us').to_i
  period = File.read('/sys/fs/cgroup/cpu/cpu.cfs_period_us').to_i
  (quota.to_f / period).ceil
rescue
  # Fallback if files can't be read
  ENV.fetch("WEB_CONCURRENCY") { 1 }.to_i
end

# Get the actual CPU allocation
cpu_allocation = get_container_cpus

# For thread-safe applications, we can use multiple threads per worker
# This allows better resource utilization and higher concurrency
# Rule of thumb: 5-10 threads per CPU core for I/O bound applications
threads_per_worker = ENV.fetch('RAILS_MAX_THREADS') { 5 }.to_i
threads threads_per_worker, threads_per_worker

# With thread-safe applications, we can use fewer workers since each worker
# can handle multiple concurrent requests through threading
# Generally: workers = CPU cores, threads = 5-10 per worker
workers cpu_allocation

# Maximum total threads = workers * threads_per_worker
# This gives us cpu_allocation * threads_per_worker total concurrent request capacity

# Preload the app before forking to save memory via Copy-On-Write
preload_app!

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port        ENV.fetch('PORT')    { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RAILS_ENV'){ 'development' }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

# Re-establish connections in each worker
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
