# Test markdown functionality

# Create a test markdown file
test_md_path = Rails.root.join('tmp', 'test_markdown.md')
File.write(test_md_path, "# Test Markdown\n\nThis is a **test** of the markdown processor.\n- Item 1\n- Item 2\n\n```ruby\nputs 'Hello, world!'\n```")

# Test MarkdownProcessor
puts "Testing MarkdownProcessor..."
html = MarkdownProcessor.process_file(test_md_path)
puts "HTML Output:"
puts "-" * 50
puts html
puts "-" * 50

# Test Post model with markdown
puts "\nTesting Post model with markdown..."
post = Post.new(
  title: "Test Markdown Post",
  slug: "test-markdown-post",
  status: :published,
  source_type: :markdown,
  file_path: test_md_path
)

puts "Post content (first 200 chars):"
puts "-" * 50
puts post.content_body[0..200] + "..."
puts "-" * 50

# Clean up
File.delete(test_md_path)

puts "\nTest completed successfully!"
