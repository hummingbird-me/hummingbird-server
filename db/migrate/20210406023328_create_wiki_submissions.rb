class CreateWikiSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :wiki_submissions do |t|
      t.string :title
      t.text :notes
      t.integer :status, null: false, default: 0
      t.jsonb :draft, null: false, default: {}

      t.references :user
      t.integer :parent_id, null: true, index: true

      t.timestamps
    end

    add_index :wiki_submissions, "(draft->'id'),(draft->'type')", name: "index_wiki_submission_on_draft_id_and_draft_type"
  end
end
