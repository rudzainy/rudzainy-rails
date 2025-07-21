# Configure SolidQueue
Rails.application.reloader.to_prepare do
  if Rails.application.config.active_job.queue_adapter == :solid_queue
    # Ensure the queue processing is enabled in production
    SolidQueue.silence_polling = false
    
    # Configure how often to poll for new jobs (in seconds)
    SolidQueue.poll_interval = 1
    
    # Enable metrics collection
    SolidQueue.metrics_collector_enabled = true
    
    # Configure the default queue processing
    SolidQueue::Process.setup(
      supervisor: true,
      polling_interval: 1,
      queues: "*"
    )
  end
end
