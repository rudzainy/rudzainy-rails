require 'yaml'
require 'redcarpet'
require 'mimemagic'
require 'mime/types'

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

# Helper method to find an image file using multiple strategies
def find_image_file(filename, original_path = '')
  # Clean up the filename
  clean_filename = filename.downcase.strip
  
  # Try exact match first
  return @image_lookup[clean_filename] if @image_lookup[clean_filename]
  
  # Try variations of the filename
  base_name = File.basename(clean_filename, '.*')
  ext = File.extname(clean_filename).downcase
  
  # Generate possible variations
  variations = [
    clean_filename,
    "#{base_name.gsub(/[-_\s]/, '')}#{ext}",
    "#{base_name.gsub(/[-_\s]/, '-')}#{ext}",
    "#{base_name.gsub(/[-_\s]/, '_')}#{ext}",
    base_name, # Just the basename without extension
    base_name.gsub(/[-_\s]/, ''),
    base_name.gsub(/[-_\s]/, '-'),
    base_name.gsub(/[-_\s]/, '_'),
    base_name.gsub(/%20/, ' '),  # Handle URL-encoded spaces
    base_name.gsub(/%20/, '_'),  # Handle URL-encoded spaces as underscores
    base_name.gsub(/%20/, '-')   # Handle URL-encoded spaces as hyphens
  ].uniq
  
  # Try each variation
  variations.each do |variant|
    # Try exact match
    if match = @image_lookup[variant]
      return match
    end
    
    # Try partial match
    @image_lookup.each_key do |key|
      if key.include?(variant) || variant.include?(key)
        return @image_lookup[key]
      end
    end
  end
  
  # If we have a path, try to find in subdirectories
  if original_path.include?('/')
    path_parts = original_path.split('/').reject(&:empty?)
    # Try to find matching directory and filename
    @image_lookup.each_key do |key|
      key_parts = key.split('/').reject(&:empty?)
      # Check if the last part matches our filename
      if key_parts.last.include?(base_name) || base_name.include?(key_parts.last)
        # Check if the directory structure is similar
        if (path_parts & key_parts).any?
          return @image_lookup[key]
        end
      end
    end
  end
  
  nil # No match found
end

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

# Get all available images in the project
puts "Indexing available images..."
all_images = []

# Look for images in multiple directories
image_dirs = [
  Rails.root.join('public', 'images', 'portfolio'),
  Rails.root.join('public', 'images', 'posts'),
  Rails.root.join('app', 'assets', 'images')
]

# Supported image extensions
IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp .svg .bmp .tiff].freeze

image_dirs.each do |dir|
  if Dir.exist?(dir)
    # Get all files with image extensions
    images = Dir.glob(File.join(dir, '**', '*')).select do |f| 
      File.file?(f) && IMAGE_EXTENSIONS.include?(File.extname(f).downcase)
    end
    all_images.concat(images)
    puts "Found #{images.size} images in #{dir}"
  end
end

# Create a lookup hash for faster searching
@image_lookup = {}
all_images.each do |path|
  # Get relative path from public or app/assets
  rel_path = path.gsub(%r{.*(public|app/assets/images)/}, '')
  
  # Store with multiple keys for flexible lookup
  filename = File.basename(path).downcase
  basename = File.basename(path, '.*').downcase
  
  # Store with original filename
  @image_lookup[filename] ||= path
  
  # Store with clean filename (no extension)
  clean_name = basename.gsub(/[^a-z0-9]/, '')
  @image_lookup[clean_name] ||= path
  
  # Store with relative path
  @image_lookup[rel_path.downcase] ||= path
  
  # Store with just the basename (no extension, no path)
  @image_lookup[File.basename(path, '.*').downcase] ||= path
  
  # Store with parent directory
  parent_dir = File.basename(File.dirname(path)).downcase
  @image_lookup["#{parent_dir}/#{filename}"] ||= path
end

puts "Total unique images found: #{all_images.uniq.size}"

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
      
      # 1. Try to find images that match the post slug
      slug_variations = [
        slug.downcase,
        slug.downcase.gsub('-', '_'),
        slug.downcase.gsub('-', ''),
        slug.downcase.split('-').first
      ].uniq
      
      # 2. Find images that match the slug variations
      slug_variations.each do |slug_var|
        if img = find_image_file(slug_var)
          matching_images << { path: img, alt: metadata['title'], original_path: slug_var }
        end
      end
      
      # 3. Check for images referenced in content using {% responsive_image %} tags
      responsive_images = markdown_content.scan(/\{%\s*responsive_?image\s+(.*?)\s*%\}/i).flatten
      
      responsive_images.each do |img_tag|
        begin
          # Extract path and alt text using a more robust parser
          path = nil
          alt = nil
          
          # Try different patterns to extract path and alt
          if img_tag =~ /path:\s*['"]([^'"]+)['"]/i
            path = $1
            alt = $1 if img_tag =~ /alt:\s*['"]([^'"]*)['"]/i
          elsif img_tag =~ /path:\s*([^\s,}]+)/i
            path = $1
            alt = $1 if img_tag =~ /alt:\s*['"]([^'"]*)['"]/i
          elsif img_tag =~ /([^\s'"%}]+\.[a-z]{3,4})/i
            path = $1
          end
          
          if path
            path = path.strip
            
            # Clean up the path
            ['assets/img/', 'assets/images/', 'img/', 'images/'].each do |prefix|
              path = path[prefix.length..-1] if path.start_with?(prefix)
            end
            
            # Try to find the image
            if img = find_image_file(path, path)
              matching_images << { path: img, alt: alt || File.basename(path, '.*').humanize, original_path: path }
            else
              puts "  - Could not find image: #{path} (from tag: #{img_tag})"
            end
          else
            puts "  - Could not parse responsive_image tag: {% #{img_tag} %}"
          end
        rescue => e
          puts "  - Error processing image tag: #{e.message}"
          next
        end
      end
      
      # Remove duplicates and nils, and ensure all entries are hashes
      matching_images = matching_images.compact.uniq.select { |img| img.is_a?(Hash) && img[:path].present? }
      
      # Set the first image as the main post image (store just the filename, not the full path)
      image_path = matching_images.any? ? File.basename(matching_images.first[:path]) : nil

      # Convert category to string and handle array case
      category = metadata['category']
      category = category.is_a?(Array) ? category.first : category
      category = (category || 'work').to_s.downcase
      
      # Create post
      post = Post.new(
        title: metadata['title'].to_s,
        slug: slug,
        content: content.to_s,
        created_at: metadata['date'] || Time.current,
        updated_at: Time.current,
        status: :published,
        category: category,
        image_path: image_path,
        source_type: :markdown,
        file_path: file_path.sub(Rails.root.to_s + '/', '') # Save relative path from Rails root
      )
      
      # Save the post first to get an ID
      if post.save
        puts "  - Post saved with ID: #{post.id}"
        
        # Store the post ID for image attachments
        post_id = post.id
        
        # Attach all matching images to the post after saving
        matching_images.each do |img_data|
          begin
            # Only attach if not already attached (check by filename to avoid duplicates)
            filename = File.basename(img_data[:path].to_s)
            
            # Skip if filename is empty
            next if filename.blank?
            
            # Reload the post to ensure we have the latest version
            post = Post.find(post_id)
            
            # Check if the image is already attached
            unless post.images.attached? { |attached_img| attached_img.filename.to_s == filename }
              # Ensure the file exists before attaching
              if File.exist?(img_data[:path].to_s)
                # Get MIME type using mime-types gem
                mime_type = MIME::Types.type_for(img_data[:path].to_s).first&.content_type || 'image/jpeg'
                
                post.images.attach(
                  io: File.open(img_data[:path].to_s),
                  filename: filename,
                  content_type: mime_type
                )
                puts "  - Attached image: #{filename} (#{mime_type})"
              else
                puts "  - Image file not found: #{img_data[:path]}"
              end
            end
          rescue => e
            puts "  - Error attaching image #{img_data[:path].inspect}: #{e.message}"
            puts "  - #{e.backtrace.first(5).join("\n  - ")}" if e.backtrace
          end
        end
      else
        puts "  - Error saving post: #{post.errors.full_messages.join(', ')}"
      end

      # Process all found images
      processed_content = markdown_content.dup
      
      # 1. Process responsive_image tags first
      processed_content = processed_content.gsub(/\{%\s*responsive_?image\s+(.*?)\s*%\}/i) do |match|
        # Extract the full match and content
        full_match = $~[0]
        tag_content = $~[1]
        
        # Extract path and alt text
        path = nil
        alt = nil
        
        # Try different patterns to extract path and alt
        if tag_content =~ /path:\s*['"]([^'"]+)['"]/i
          path = $1
          alt = $1 if tag_content =~ /alt:\s*['"]([^'"]*)['"]/i
        elsif tag_content =~ /path:\s*([^\s,}]+)/i
          path = $1
          alt = $1 if tag_content =~ /alt:\s*['"]([^'"]*)['"]/i
        elsif tag_content =~ /([^\s'"%}]+\.[a-z]{3,4})/i
          path = $1
        end
        
        if path
          path = path.strip
          
          # Clean up the path
          ['assets/img/', 'assets/images/', 'img/', 'images/'].each do |prefix|
            path = path[prefix.length..-1] if path.start_with?(prefix)
          end
          
          # Try to find the image
          if img = find_image_file(path, path)
            # Attach the file to the post
            filename = File.basename(img)
            
            # Check if already attached to avoid duplicates
            unless post.images.any? { |a| a.filename.to_s.downcase == filename.downcase }
              post.images.attach(io: File.open(img), filename: filename)
            end
            
            # Get the attached file
            attached_file = post.images.find { |a| a.filename.to_s.downcase == filename.downcase }
            
            if attached_file
              # Generate the image URL
              img_url = Rails.application.routes.url_helpers.rails_blob_path(attached_file, only_path: true)
              
              # Return a nice HTML figure with the image
              alt_text = alt || File.basename(path, '.*').humanize
              "<figure class=\"post-image\">\n  <img src=\"#{img_url}\" alt=\"#{alt_text}\">\n  #{alt_text.present? ? "<figcaption>#{alt_text}</figcaption>" : ""}\n</figure>"
            else
              "<!-- Failed to attach image: #{filename} -->"
            end
          else
            "<!-- Image not found: #{path} -->"
          end
        else
          "<!-- Could not parse image tag: #{full_match} -->"
        end
      end
      
      # 2. Convert markdown to HTML
      html_content = markdown.render(processed_content)
      
      # 3. Process any remaining images in the content
      # This handles standard markdown images: ![alt](path/to/image.jpg)
      html_content = html_content.gsub(/<img[^>]+src=["']([^"']+)["'][^>]*>/) do |img_tag|
        src = $1
        
        # Skip if it's already a data URL or absolute URL
        next img_tag if src.start_with?('data:', 'http://', 'https://', '/assets/')
        
        # Clean up the path
        clean_src = src.gsub(%r{^/}, '')
        
        # Try to find the image
        if img = find_image_file(clean_src, clean_src)
          filename = File.basename(img)
          
          # Attach if not already attached
          unless post.images.any? { |a| a.filename.to_s.downcase == filename.downcase }
            post.images.attach(io: File.open(img), filename: filename)
          end
          
          # Get the attached file
          attached_file = post.images.find { |a| a.filename.to_s.downcase == filename.downcase }
          
          if attached_file
            # Generate the image URL
            img_url = Rails.application.routes.url_helpers.rails_blob_path(attached_file, only_path: true)
            
            # Replace the src with the new URL
            img_tag.gsub(/src=["'][^"']*["']/, "src=\"#{img_url}\"")
          else
            img_tag
          end
        else
          img_tag
        end
      end
      
      # Set the content as rich text
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

# Special case: Hardcode image paths for Hoojah Project post
puts "\nUpdating Hoojah Project post with hardcoded image paths..."
hoojah_post = Post.find_by(slug: 'the-hoojah-project')

if hoojah_post
  # Hardcoded images for Hoojah Project with their corresponding alt text
  hoojah_images = [
    { 
      path: 'hoojah/thumbnail-hoojah.jpg', 
      filename: 'thumbnail-hoojah.jpg',
      alt: 'Hoojah Project Thumbnail'
    },
    { 
      path: 'hoojah/Home-User.png', 
      filename: 'Home-User.png',
      alt: 'Home page showing timeline view of recently updated polls. Desktop users would be able to see additional information in the left and right sidebars.'
    },
    { 
      path: 'hoojah/User-Show-Votes.png', 
      filename: 'User-Show-Votes.png',
      alt: 'User profile page showing all participated (and possibly trending or promoted) polls by the user.'
    },
    { 
      path: 'hoojah/Poll-Show-User.png', 
      filename: 'Poll-Show-User.png',
      alt: 'A poll page, illustrating three main interactions a user can engage with a poll. Users can vote, add supporting arguments under each vote option independently of their personal vote, as well as engage in a one-on-one debate with another user.'
    },
    { 
      path: 'hoojah/Debate-Show-Ended.png', 
      filename: 'Debate-Show-Ended.png',
      alt: 'A one-on-one debate page (seems to be getting good traction, probably because of the two well known public figure debating... interesting stuff).'
    },
    { 
      path: 'hoojah/Business-Search.png', 
      filename: 'Business-Search.png',
      alt: 'Analytic page for business tier users.'
    },
    { 
      path: 'hoojah/Log-In.png', 
      filename: 'Log-In.png',
      alt: 'The log in and sign up feature is combined into a single page. Log in takes priority over sign up, therefore on mobile, the sign up form would be pushed down.'
    },
    { 
      path: 'hoojah/Poll-New.png', 
      filename: 'Poll-New.png',
      alt: 'Registered users can create new polls with some options for customization.'
    },
    { 
      path: 'hoojah/User-Show-Polls.png', 
      filename: 'User-Show-Polls.png',
      alt: 'Alternative design of user profile page with badges. The idea for badges came from the need to group user interests together, where a badge could be affiliated with user groups, active categories or user achievements.'
    }
  ].map do |img|
    # Try to find the image in multiple directories
    search_paths = [
      Rails.root.join('public', 'images', 'posts', img[:path]),
      Rails.root.join('public', 'images', 'portfolio', img[:path]),
      Rails.root.join('app', 'assets', 'images', img[:path]),
      Rails.root.join('public', 'images', img[:path]),
      Rails.root.join('public', 'images', 'posts', File.basename(img[:path])),
      Rails.root.join('public', 'images', 'portfolio', File.basename(img[:path])),
      Rails.root.join('app', 'assets', 'images', File.basename(img[:path]))
    ]
    
    found_path = search_paths.find { |path| File.exist?(path) }
    
    if found_path
      { path: found_path, alt: img[:alt], filename: File.basename(img[:path]) }
    else
      puts "  - Warning: Could not find image: #{img[:path]}"
      puts "    Searched in: " + search_paths.map { |p| p.to_s.gsub(Rails.root.to_s, '') }.join(', ')
      nil
    end
  end.compact

  # Clear existing images
  hoojah_post.images.purge

  # Attach new images
  hoojah_images.each_with_index do |img, index|
    img_path = img[:path].to_s  # Convert Pathname to string
    
    if File.exist?(img_path)
      mime_type = MIME::Types.type_for(img_path).first&.content_type || 'image/jpeg'
      filename = img[:filename] || File.basename(img_path)
      
      begin
        hoojah_post.images.attach(
          io: File.open(img_path),
          filename: filename,
          content_type: mime_type,
          identify: false
        )
        
        # Set the first image as the main image if it contains 'thumbnail' or if it's the first image
        if (img_path.include?('thumbnail') || index == 0) && hoojah_post.image_path.blank?
          hoojah_post.update(image_path: filename)
          puts "  - Set as main image: #{filename} (#{mime_type})"
        else
          puts "  - Attached image: #{filename} (#{mime_type})"
        end
      rescue => e
        puts "  - Error attaching image #{filename}: #{e.message}"
      end
    else
      puts "  - Image not found: #{img_path}"
    end
  end
  
  # Get the current content as HTML
  content = hoojah_post.content.body.to_html
  
  # Create a mapping of image filenames to their Active Storage URLs
  image_urls = {}
  
  if hoojah_post.images.attached?
    puts "\n=== Processing Hoojah Project Post (ID: #{hoojah_post.id}) ==="
    
    # First, log all attached images
    puts "\nAttached images:"
    hoojah_post.images.each do |image|
      filename = image.filename.to_s
      image_url = Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
      image_urls[filename.downcase] = image_url
      puts "  - #{filename} => #{image_url}"
    end
    
    # Log the hoojah_images we're trying to match
    puts "\nHoojah images to process:"
    hoojah_images.each do |img|
      filename = File.basename(img[:filename])
      puts "  - #{filename} (alt: #{img[:alt][0..50]}...)"
    end
    
    # For debugging, show the current content before any changes
    puts "\nCurrent content (first 500 chars):"
    puts content[0..500] + "...\n"
    
    # First, extract all image tags from the content
    image_tags = content.scan(/<img[^>]+>/)
    puts "\nFound #{image_tags.size} image tags in content"
    
    # Process each image tag
    image_tags.each_with_index do |img_tag, index|
      puts "\nProcessing image tag #{index + 1}:"
      puts "  - Original tag: #{img_tag}"
      
      # Extract src and alt attributes
      src_match = img_tag.match(/src=["']([^"']+)["']/i)
      alt_match = img_tag.match(/alt=["']([^"']*)["']/i)
      
      if src_match && src_match[1]
        src = src_match[1]
        alt = alt_match && alt_match[1] ? alt_match[1] : ""
        
        puts "  - Current src: #{src}"
        puts "  - Current alt: #{alt}"
        
        # Find the matching image from our hoojah_images
        matching_image = hoojah_images.find do |img|
          filename = File.basename(img[:filename])
          alt.include?(img[:alt][0..30]) ||  # Check if alt text matches partially
          src.include?(filename)             # Or if src contains the filename
        end
        
        if matching_image
          filename = File.basename(matching_image[:filename])
          if image_url = image_urls[filename.downcase]
            puts "  - Found matching image: #{filename}"
            puts "  - New URL: #{image_url}"
            
            # Replace the src in the img tag
            new_tag = img_tag.gsub(/src=["'][^"']*["']/i, "src=\"#{image_url}\"")
            
            # Update the content with the new tag
            content = content.gsub(img_tag, new_tag)
            
            puts "  - Updated tag: #{new_tag}"
          else
            puts "  - No URL found for attached image: #{filename}"
          end
        else
          puts "  - No matching image found for this tag"
        end
      else
        puts "  - No src attribute found in image tag"
      end
    end
    
    # For debugging, show the updated content
    puts "\nUpdated content (first 500 chars):"
    puts content[0..500] + "..."
    
    # Update the post content with the fixed image URLs
    hoojah_post.update(content: content)
    puts "\n=== Updated post content with fixed image URLs ==="
    
    # Verify the update was successful
    updated_post = Post.find(hoojah_post.id)
    puts "Post content updated? #{updated_post.content.body.to_s.include?('rails/active_storage') ? 'Yes' : 'No'}"
  else
    puts "\nNo images attached to the Hoojah Project post!"
  end
  
  # Also replace any responsive_image tags with standard markdown image syntax
  content = content.gsub(
    /\{%\s*responsive_image\s+path:\s*['"]([^'"\s}]+)['"][^%]*%\}/i
  ) do |match|
    filename = $1
    # Try to find the image in our attached images
    if image_urls[filename]
      "![#{filename}](#{image_urls[filename]})"
    else
      # Fall back to the original path structure
      "![#{filename}](/images/posts/hoojah/#{filename})"
    end
  end
  
  # Handle responsive_image tags with alt text
  content = content.gsub(
    /\{%\s*responsive_image\s+path:\s*['"]([^'"\s}]+)['"][^%]*alt:\s*['"]([^'"]+)['"][^%]*%\}/i
  ) do |match|
    filename = $1
    alt_text = $2
    # Try to find the image in our attached images
    if image_urls[filename]
      "![#{alt_text}](#{image_urls[filename]})"
    else
      # Fall back to the original path structure
      "![#{alt_text}](/images/posts/hoojah/#{filename})"
    end
  end
  
  # Update the post content if it has changed
  if content != hoojah_post.content.body.to_s
    hoojah_post.update(content: content)
    puts "  - Updated post content with new image paths"
  else
    puts "  - No image path updates needed in content"
  end
  
  puts "✓ Updated Hoojah Project post with hardcoded images"
else
  puts "! Hoojah Project post not found. Skipping hardcoded image update."
end

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
