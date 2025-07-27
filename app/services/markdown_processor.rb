class MarkdownProcessor
  class << self
    def to_html(markdown_text)
      return "" if markdown_text.blank?
      
      renderer = Redcarpet::Render::HTML.new(
        filter_html: true,
        hard_wrap: true,
        with_toc_data: true,
        prettify: true,
        link_attributes: { target: '_blank', rel: 'noopener' }
      )
      
      extensions = {
        autolink: true,
        no_intra_emphasis: true,
        fenced_code_blocks: true,
        lax_html_blocks: true,
        strikethrough: true,
        superscript: true,
        tables: true
      }
      
      markdown = Redcarpet::Markdown.new(renderer, extensions)
      markdown.render(markdown_text).html_safe
    end
    
    def process_file(file_path)
      return "" unless file_path.present? && File.exist?(file_path)
      
      content = File.read(file_path)
      to_html(content)
    end
  end
end
