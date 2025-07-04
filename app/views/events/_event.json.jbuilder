json.extract! event, :id, :title, :subtitle, :location, :start_date, :end_date, :remarks, :category, :highlight, :created_at, :updated_at
json.url event_url(event, format: :json)
