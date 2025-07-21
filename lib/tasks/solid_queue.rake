namespace :solid_queue do
  desc 'Start SolidQueue workers'
  task :start_workers do
    if Rails.env.production? && ENV['SOLID_QUEUE_WORKERS'] != 'false'
      require 'solid_queue/worker'
      
      # Start the supervisor process
      supervisor = SolidQueue::Supervisor.new(
        polling_interval: 1,
        batch_size: 50,
        threads: ENV.fetch('SOLID_QUEUE_THREADS', 5).to_i,
        queues: ENV.fetch('SOLID_QUEUE_QUEUES', '*'),
        processes: ENV.fetch('SOLID_QUEUE_PROCESSES', 1).to_i
      )
      
      # Handle shutdown signals
      trap('TERM') { supervisor.shutdown }
      trap('INT')  { supervisor.shutdown }
      
      # Start the supervisor
      supervisor.start
    end
  end
end
