module Media
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    include Titleable
    include Rateable

    # HACK: we need to return a relation but want to handle historical slugs
    scope :by_slug, -> (slug) {
      record = where(slug: slug)
      record = where(id: friendly.find(slug).id) if record.empty?
      record
    }

    friendly_id :slug_candidates, use: %i[slugged finders history]
    resourcify
    has_attached_file :cover_image
    has_attached_file :poster_image
    update_index("media##{name.underscore}") { self }

    has_and_belongs_to_many :genres
    has_many :castings, as: 'media'
    has_many :installments, as: 'media'
    has_many :franchises, through: :installments
    has_many :library_entries, as: 'media', dependent: :destroy
    has_many :mappings, as: 'media', dependent: :destroy
    delegate :year, to: :start_date, allow_nil: true

    validates_attachment :cover_image, content_type: {
      content_type: %w[image/jpg image/jpeg image/png]
    }
    validates_attachment :poster_image, content_type: {
      content_type: %w[image/jpg image/jpeg image/png]
    }

    after_create :follow_self
  end

  def slug_candidates
    [
      -> { canonical_title },
      -> { titles[:en_jp] }
    ]
  end

  # How long the series ran for, or nil if the start date is unknown
  def run_length
    (end_date || Date.today) - start_date if start_date
  end

  def feed
    @feed ||= Feed.media(self.class.name, id)
  end

  def aggregated_feed
    @aggregated_feed ||= Feed.media_aggr(self.class.name, id)
  end

  def follow_self
    aggregated_feed.follow(feed)
  end
end
