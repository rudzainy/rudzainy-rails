# Run the web process
web: bundle exec rails server -p $PORT -e $RAILS_ENV

# Run SolidQueue workers
worker: bundle exec rake solid_queue:start_workers

# Run the release command for database migrations (used by Render.com)
release: |
  bundle exec rails db:migrate
  bundle exec rails db:migrate:queue
  bundle exec rails solid_queue:install:migrations
  bundle exec rails db:migrate:queue
