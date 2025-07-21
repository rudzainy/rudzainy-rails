require 'yaml'
require 'redcarpet'

# Clear existing posts
puts "Clearing existing posts..."
Post.destroy_all

# Directory containing markdown files
posts_dir = Rails.root.join('db', 'dump', '_posts')
posts_image_dir = Rails.root.join('public', 'images', 'posts')

# Counter for tracking progress
total_files = Dir.glob(File.join(posts_dir, '*.md')).count
imported_count = 0

puts "Found #{total_files} markdown files to import"

# Initialize Redcarpet markdown renderer
renderer = Redcarpet::Render::HTML.new(
  filter_html: false,
  no_links: false,
  no_images: false,
  with_toc_data: true,
  hard_wrap: true
)
markdown = Redcarpet::Markdown.new(renderer, 
  autolink: true,
  tables: true,
  fenced_code_blocks: true,
  strikethrough: true,
  superscript: true,
  underline: true,
  quote: true,
  footnotes: true
)

# Helper method to determine post category based on content and title
def determine_category(title, content, metadata)
  # Keywords for categorization
  work_keywords = [ 'design', 'development', 'programming', 'rails', 'ruby', 'javascript', 'react', 'ui', 'ux', 'app', 'website', 'tutorial', 'code', 'developer', 'engineer' ]
  life_keywords = [ 'life', 'family', 'personal', 'journey', 'experience', 'travel', 'adventure', 'reflection', 'thoughts', 'diary', 'log' ]

  # Check title first (weighted more heavily)
  title_downcase = title.downcase

  # Direct category mapping from metadata if available
  return metadata['category'].to_sym if metadata['category'].present? && [ 'work', 'life', 'balance' ].include?(metadata['category'])

  # Check for explicit category indicators in title
  return :work if work_keywords.any? { |keyword| title_downcase.include?(keyword) }
  return :life if life_keywords.any? { |keyword| title_downcase.include?(keyword) }

  # If no clear category from title, use a simple content analysis
  content_downcase = content.downcase
  work_count = work_keywords.sum { |keyword| content_downcase.scan(keyword).count }
  life_count = life_keywords.sum { |keyword| content_downcase.scan(keyword).count }

  if work_count > life_count
    :work
  elsif life_count > work_count
    :life
  else
    # Default to balance if we can't determine
    :balance
  end
end

# Get all available images in the posts directory
puts "Indexing available images..."
all_images = Dir.glob(File.join(posts_image_dir, '**', '*')).select { |f| File.file?(f) }
puts "Found #{all_images.size} images"

# Create a hash of image paths for easier lookup
image_paths = {}
all_images.each do |path|
  # Get the filename without extension
  filename = File.basename(path, '.*').downcase
  # Remove common prefixes like "Screenshot_" and replace special chars with dashes
  clean_filename = filename.gsub(/^screenshot_\d{4}-\d{2}-\d{2}_at_/, '')
                          .gsub(/[^a-z0-9]+/, '-')
  
  # Store both the original and cleaned filename for matching
  image_paths[filename] = path
  image_paths[clean_filename] = path
  
  # Also store by parent directory name if in a subdirectory
  parent_dir = File.basename(File.dirname(path))
  if parent_dir != 'posts'
    image_paths[parent_dir] = path unless image_paths[parent_dir]
  end
end

Dir.glob(File.join(posts_dir, '*.md')).each do |file_path|
  begin
    # Read the file content
    content = File.read(file_path)

    # Extract YAML front matter
    if content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)\z/m
      yaml_content = $1
      markdown_content = $2.strip

      # Parse YAML front matter
      metadata = YAML.safe_load(yaml_content)

      # Get the filename without extension to use as fallback slug
      filename = File.basename(file_path, '.md')
      date_slug_match = filename.match(/^\d{4}-\d{2}-\d{2}-(.+)$/)
      slug = date_slug_match ? date_slug_match[1] : filename

      # Determine category
      category = determine_category(metadata['title'], markdown_content, metadata)

      # Find images that match the post slug
      matching_images = []
      
      # Try direct slug match
      slug_clean = slug.downcase
      if image_paths[slug_clean]
        matching_images << image_paths[slug_clean]
      end
      
      # Try variations of the slug
      slug_variations = [
        slug_clean,
        slug_clean.gsub('-', '_'),
        slug_clean.gsub('-', ''),
        slug_clean.split('-').first
      ]
      
      slug_variations.each do |variation|
        all_images.each do |img_path|
          if File.basename(img_path, '.*').downcase.include?(variation)
            matching_images << img_path
          end
        end
      end
      
      # Check for images referenced in content using {% responsiveimage path: ... %} tags
      responsive_images = markdown_content.scan(/\{%\s*responsiveimage\s+path:\s*([^%]+)\s*%\}/).flatten
      responsive_images.each do |img_ref|
        # Extract the filename from the path
        filename = img_ref.strip.split('/').last
        
        # Look for matching image in our directory
        all_images.each do |img_path|
          if File.basename(img_path).downcase.include?(filename.downcase)
            matching_images << img_path
          end
        end
      end
      
      # Remove duplicates
      matching_images.uniq!
      
      # Set image_path if we found matching images
      image_path = nil
      if matching_images.any?
        # Extract just the filename and any subdirectories, without the /images/posts/ prefix
        # This is because the view already prepends /images/posts/ to the path
        path_parts = matching_images.first.split('public/images/posts/')
        if path_parts.size > 1
          image_path = path_parts.last
        end
      end

      # Create post
      post = Post.new(
        title: metadata['title'],
        slug: slug,
        status: metadata['published'] == false ? :draft : :published,
        category: category,
        created_at: metadata['date'] || File.ctime(file_path),
        updated_at: File.mtime(file_path),
        image_path: image_path
      )

      # Convert markdown to HTML and set content
      html_content = markdown.render(markdown_content)
      
      # For posts with multiple images, update the content to include them
      if matching_images.size > 1
        puts "  - Post '#{post.title}' has #{matching_images.size} matching images"
        
        # Process the content to include additional images
        # We'll keep the first image as the post.image_path and add the rest to the content
        additional_images = matching_images[1..-1]
        
        # Add remaining images as HTML img tags at the end of the content
        matching_images[1..].each do |img_path|
          # Extract the path relative to /public/images/posts for additional images
          path_parts = img_path.split('public/images/posts/')
          if path_parts.size > 1
            # Use the full path for embedded images
            img_url = "/images/posts/" + path_parts.last
            html_content += "\n<img src=\"#{img_url}\" alt=\"Additional image\">\n"
          end
        end
      end
      
      post.content = html_content

      # Set tldr if description exists
      if metadata['description'].present?
        post.tldr = metadata['description']
      else
        # Generate a simple tldr from the first paragraph of content if no description
        first_paragraph = markdown_content.split("\n\n").first
        post.tldr = first_paragraph.truncate(150) if first_paragraph.present?
      end

      # Save the post
      if post.save
        imported_count += 1
        puts "Imported: #{post.title} (#{imported_count}/#{total_files}) - Category: #{category}"
        if post.image_path.present?
          puts "  - Set image_path to: #{post.image_path}"
        else
          puts "  - No matching images found"
        end
      else
        puts "Failed to import #{file_path}: #{post.errors.full_messages.join(', ')}"
      end
    else
      puts "Skipping #{file_path}: Invalid markdown format (missing YAML front matter)"
    end
  rescue => e
    puts "Error processing #{file_path}: #{e.message}"
  end
end

puts "Import complete! #{imported_count} posts imported."

# Update specific posts with known categories
posts_to_update = {
  # Technical/work posts
  'regular-expressions-in-javascript': :work,
  'rails-drag-and-drop': :work,
  'rails-image-tag': :work,
  'rails-7-dropdown-image': :work,
  'rails-7-turbo-frame': :work,
  'how-to-validate-an-email-address-in-rails': :work,
  'of-javascript': :work,
  'reactjs-and-rails-the-hoojah': :work,
  'restarting-postgres-for-rails-on-macos': :work,
  'tutorial-ruby-on-rails': :work,
  'setup-python-3-on-macos': :work,
  'tutorial-generate-qr-for-wifi': :work,
  'add-diagram-on-websites-using-mermaidjs': :work,
  'converting-mov-to-animated-gif-in-macos': :work,

  # Life/personal posts
  'family': :life,
  'life': :life,
  'self-improvement': :life,
  'thoughts-explosion': :life,
  'of-books': :life,
  'of-video-games': :life,
  'krabi-logs': :life,
  'ranting': :life,
  'current-state-of-malaysia': :life,

  # Balance/mixed posts
  'the-framework': :balance,
  'of-operating-systems': :balance,
  'an-answer-to-the-question-of-windows-vs-macos': :balance,
  'users-vs-corporations-in-digital-communication': :balance,
  'why-rigid-corporate-structure-is-bad-for-me': :balance,
  'of-workshops': :balance
}

puts "\nUpdating specific post categories..."
updated_count = 0

posts_to_update.each do |slug, category|
  post = Post.find_by(slug: slug)
  if post
    post.update(category: category)
    updated_count += 1
    puts "Updated '#{post.title}' to category: #{category}"
  end
end

puts "Updated #{updated_count} posts with specific categories"
