namespace :posts do
  desc "Assign images to posts based on content and slug matching"
  task assign_images: :environment do
    # Get all available images in the posts directory
    posts_image_dir = Rails.root.join('public', 'images', 'posts')
    all_images = Dir.glob(File.join(posts_image_dir, '**', '*')).select { |f| File.file?(f) }
    
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
        image_paths[parent_dir] = path
      end
    end
    
    # Process each post
    Post.find_each do |post|
      puts "Processing post: #{post.title} (#{post.slug})"
      
      # Skip if image_path is already set
      if post.image_path.present?
        puts "  - Already has image_path: #{post.image_path}"
        next
      end
      
      # Find images that match the post slug
      matching_images = []
      
      # Try direct slug match
      slug = post.slug.downcase
      if image_paths[slug]
        matching_images << image_paths[slug]
      end
      
      # Try variations of the slug
      slug_variations = [
        slug,
        slug.gsub('-', '_'),
        slug.gsub('-', ''),
        slug.split('-').first
      ]
      
      slug_variations.each do |variation|
        all_images.each do |img_path|
          if File.basename(img_path, '.*').downcase.include?(variation)
            matching_images << img_path
          end
        end
      end
      
      # Check for images referenced in content
      content_text = post.content.to_plain_text
      
      # Check for {% responsiveimage path: ... %} tags
      responsive_images = content_text.scan(/\{% responsiveimage path: ([^%]+) %}/).flatten
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
      
      # Check for <img src=...> tags
      img_tags = post.content.body.to_s.scan(/<img src="([^"]+)"/).flatten
      img_tags.each do |src|
        # Extract the filename from the path
        filename = src.strip.split('/').last
        
        # Look for matching image in our directory
        all_images.each do |img_path|
          if File.basename(img_path).downcase.include?(filename.downcase)
            matching_images << img_path
          end
        end
      end
      
      # Remove duplicates and get unique image paths
      matching_images.uniq!
      
      # If we found matching images
      if matching_images.any?
        # Use the first image for image_path
        relative_path = matching_images.first.sub("#{Rails.root}/public", '')
        post.image_path = relative_path
        puts "  - Setting image_path to: #{relative_path}"
        
        # Save the post
        if post.save
          puts "  - Successfully updated post"
        else
          puts "  - Failed to update post: #{post.errors.full_messages.join(', ')}"
        end
      else
        puts "  - No matching images found"
      end
    end
    
    puts "Done assigning images to posts!"
  end
end
