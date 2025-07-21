# Configure SolidQueue
Rails.application.reloader.to_prepare do
  if Rails.application.config.active_job.queue_adapter == :solid_queue
    # Configure SolidQueue with default options
    SolidQueue.configure do |config|
      # Enable polling for jobs
      config.silence_polling = false
      
      # Enable metrics collection
      config.metrics_collector_enabled = true
    end
  end
end
