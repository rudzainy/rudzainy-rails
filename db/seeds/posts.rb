require 'yaml'

# Clear existing posts
puts "Clearing existing posts..."
Post.destroy_all

# Directory containing markdown files
posts_dir = Rails.root.join('db', 'dump', '_posts')

# Counter for tracking progress
total_files = Dir.glob(File.join(posts_dir, '*.md')).count
imported_count = 0

puts "Found #{total_files} markdown files to import"

# Helper method to determine post category based on content and title
def determine_category(title, content, metadata)
  # Keywords for categorization
  work_keywords = ['design', 'development', 'programming', 'rails', 'ruby', 'javascript', 'react', 'ui', 'ux', 'app', 'website', 'tutorial', 'code', 'developer', 'engineer']
  life_keywords = ['life', 'family', 'personal', 'journey', 'experience', 'travel', 'adventure', 'reflection', 'thoughts', 'diary', 'log']
  
  # Check title first (weighted more heavily)
  title_downcase = title.downcase
  
  # Direct category mapping from metadata if available
  return metadata['category'].to_sym if metadata['category'].present? && ['work', 'life', 'balance'].include?(metadata['category'])
  
  # Check for explicit category indicators in title
  return :work if work_keywords.any? { |keyword| title_downcase.include?(keyword) }
  return :life if life_keywords.any? { |keyword| title_downcase.include?(keyword) }
  
  # If no clear category from title, use a simple content analysis
  content_downcase = content.downcase
  work_count = work_keywords.sum { |keyword| content_downcase.scan(keyword).count }
  life_count = life_keywords.sum { |keyword| content_downcase.scan(keyword).count }
  
  if work_count > life_count
    return :work
  elsif life_count > work_count
    return :life
  else
    # Default to balance if we can't determine
    return :balance
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
      
      # Create post
      post = Post.new(
        title: metadata['title'],
        slug: slug,
        status: metadata['published'] == false ? :draft : :published,
        category: category,
        created_at: metadata['date'] || File.ctime(file_path),
        updated_at: File.mtime(file_path)
      )
      
      # Set content
      post.content = markdown_content
      
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
