class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

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
  
  enum :source_type, {
    database: 0,
    markdown: 1
  }, default: :database
  
  # Virtual attribute for markdown content
  attr_accessor :markdown_content
  
  # Callbacks
  before_validation :set_slug, if: :title_changed?
  before_save :process_markdown, if: -> { markdown? && markdown_content.present? }
  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  # Returns the content based on the source type
  def content_body
    return content.body.to_s if database?
    return markdown_to_html if markdown? && file_path.present? && File.exist?(markdown_file_path)
    ""
  end
  
  # Returns the tldr based on the source type
  def tldr_body
    return tldr.body.to_s if database? || tldr.body.present?
    ""
  end
  
  # Returns the URL for the main post image
  def main_image_url
    # In production, prioritize public images to avoid Active Storage issues
    if Rails.env.production?
      # If we have an image_path, try to find it in the public directory
      if image_path.present?
        filename = File.basename(image_path)
        
        # Check common subdirectories for the image
        subdirs = ['posts', 'portfolio']
        
        subdirs.each do |subdir|
          # Return the path with the subdirectory if it exists in the repo
          return "/images/#{subdir}/#{filename}"
        end
        
        # If not found in subdirectories, try the root images directory
        return "/images/#{filename}"
      end
      
      # Default to a placeholder in production
      return "/images/500x300.png"
    else
      # In development/test, use the normal flow
      # If we have an image_path but no attached images, try to find it in the public directory
      if image_path.present?
        filename = File.basename(image_path)
        
        # Check in root images directory
        public_path = Rails.root.join('public', 'images', filename).to_s
        if File.exist?(public_path)
          return "/images/#{filename}"
        end
        
        # Check in posts subdirectory
        posts_path = Rails.root.join('public', 'images', 'posts', filename).to_s
        if File.exist?(posts_path)
          return "/images/posts/#{filename}"
        end
        
        # Check in portfolio subdirectory
        portfolio_path = Rails.root.join('public', 'images', 'portfolio', filename).to_s
        if File.exist?(portfolio_path)
          return "/images/portfolio/#{filename}"
        end
      end
      
      # If we have attached images, use the first one
      if images.attached?
        # Return the first attached image
        return Rails.application.routes.url_helpers.rails_blob_url(images.first, only_path: true)
      end
      
      # Default image if none found
      "/images/500x300.png"
    end
  end
  
  # This method was private initially. Need to relook if it should be private or public.
  def markdown_file_path
    return nil if file_path.blank?
    Rails.root.join(file_path).to_s
  end
  # also this one
  def markdown_to_html
    MarkdownProcessor.process_file(markdown_file_path)
  end
  
  private
  
  def set_slug
    self.slug = title.parameterize if title.present?
  end
  
  def process_markdown
    # Save the markdown content to a file
    dir = Rails.root.join('db', 'dump', '_posts')
    FileUtils.mkdir_p(dir)
    
    filename = "#{Time.now.strftime('%Y-%m-%d')}-#{slug}.md"
    self.file_path = File.join('db', 'dump', '_posts', filename)
    
    File.write(Rails.root.join(file_path), markdown_content)
  end
end
