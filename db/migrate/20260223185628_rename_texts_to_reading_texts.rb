class RenameTextsToReadingTexts < ActiveRecord::Migration[8.1]
  def change
  rename_table :texts, :reading_texts
end

end
