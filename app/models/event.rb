class Event < ApplicationRecord

  has_rich_text :content

  enum :category, {
    employment: 0,
    freelancing: 1,
    education: 2
  }
end
