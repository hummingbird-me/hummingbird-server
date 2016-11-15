class FavoriteResource < BaseResource
  attributes :fav_rank

  has_one :user
  has_one :item, polymorphic: true

  filters :user_id, :item_type
end
