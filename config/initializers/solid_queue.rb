# Configure SolidQueue
Rails.application.reloader.to_prepare do
  if Rails.application.config.active_job.queue_adapter == :solid_queue
    # Enable polling for jobs
    SolidQueue.silence_polling = false if SolidQueue.respond_to?(:silence_polling=)
  end
end
