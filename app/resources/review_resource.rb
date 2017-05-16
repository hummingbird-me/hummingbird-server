class ReviewResource < BaseResource
  attributes :content, :content_formatted, :likes_count, :progress, :rating,
    :source, :spoiler, :created_at, :updated_at

  caching

  has_one :library_entry
  has_one :media, polymorphic: true
  has_one :user

  filters :media_id, :media_type, :user_id
end
