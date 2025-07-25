class AddMarkdownSupportToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :source_type, :integer
    add_column :posts, :file_path, :string
  end
end
