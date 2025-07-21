class Post < ApplicationRecord
  has_many_attached :images
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

  # Returns the URL for the main post image
  def main_image_url
    # If we have attached images, use the first one
    if images.attached?
      # Return the first attached image
      return Rails.application.routes.url_helpers.rails_blob_url(images.first, only_path: true)
    end
    
    # If we have an image_path but no attached images, try to find it in the public directory
    if image_path.present?
      # Check if the file exists in the public/images directory
      filename = File.basename(image_path)
      public_path = Rails.root.join('public', 'images', filename).to_s
      
      if File.exist?(public_path)
        # If the file exists in public/images, return its URL
        return "/images/#{filename}"
      end
    end
    
    # Default image if none found
    "/images/placeholder.png"
  end
end
