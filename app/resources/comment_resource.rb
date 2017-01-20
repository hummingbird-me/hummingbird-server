class CommentResource < BaseResource
  caching

  attributes :content, :content_formatted, :blocked, :deleted_at, :created_at,
    :likes_count, :replies_count, :updated_at, :edited_at

  has_one :user
  has_one :post
  has_one :parent
  has_many :likes
  has_many :replies

  filters :post_id, :parent_id
end
