json.extract! post, :id, :title, :slug, :status, :created_at, :updated_at
json.url post_url(post, format: :json)
