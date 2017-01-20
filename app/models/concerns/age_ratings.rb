module AgeRatings
  extend ActiveSupport::Concern

  AGE_RATINGS = %i[G PG R R18].freeze
  SAFE_AGE_RATINGS = %w[G PG R].freeze

  # SFW-ness is whitelist, not blacklist
  def sfw?
    age_rating.in?(SAFE_AGE_RATINGS) || age_rating.nil?
  end

  def nsfw?
    !sfw?
  end

  included do
    enum age_rating: AGE_RATINGS

    scope :sfw, -> {
      where(age_rating: age_ratings.values_at(*SAFE_AGE_RATINGS) + [nil])
    }
  end
end
