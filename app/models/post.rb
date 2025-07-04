class Post < ApplicationRecord
  has_rich_text :content
  has_rich_text :tldr
  enum :status, {
    draft: 0,
    published: 1
  }, default: :draft
  enum :category, {
    work: 0,
    life: 1,
    balance: 2
  }, default: :balance
  validates :title, :slug, presence: true
  validates :slug, uniqueness: true
end
