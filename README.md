# of Rudzainy Rahman

This is my personal corner of the internet - built with Rails 8, where I share my life events and random thoughts.

## What's in it?

- A timeline of stuff that's happened in my life
- Blog posts where I ramble about things

## Getting started

### Grab the code

```bash
git clone https://github.com/rudzainy/rudzainy-rails.git
cd rudzainy-rails
```

### Set things up

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

Then hit up `http://localhost:3000` in the browser.

## Putting it online

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/rudzainy/rudzainy-rails)

### Manual way

1. Make a Postgres DB on Render
2. Create a Web Service
3. Connect to GitHub repo
4. Add these environment variables:
   - `DATABASE_URL`: Postgres connection string
   - `RAILS_MASTER_KEY`: Rails master key
   - `RAILS_ENV`: production

## Dev stuff

### Tests

```bash
rails test
```

### Keeping it clean

Use Rubocop to catch my bad habits:

```bash
bundle exec rubocop
```

