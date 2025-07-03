class Post < ApplicationRecord

  has_rich_text :content

  enum :status, { draft: 0, published: 1 }, default: :draft

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true


end
