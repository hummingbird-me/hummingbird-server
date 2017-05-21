module Media
  extend ActiveSupport::Concern

  STATUSES = %w[nya upcoming current finished]

  included do
    include Titleable
    include Rateable
    include Rankable
    include Trendable
    include WithCoverImage
    include Sluggable

    friendly_id :slug_candidates, use: %i[slugged finders history]
    resourcify
    has_attached_file :poster_image, styles: {
      tiny: ['110x156#', :jpg],
      small: ['284x402#', :jpg],
      medium: ['390x554#', :jpg],
      large: ['550x780#', :jpg]
    }, convert_options: {
      tiny: '-quality 90 -strip',
      small: '-quality 75 -strip',
      medium: '-quality 70 -strip',
      large: '-quality 60 -strip'
    }

    update_index("media##{name.underscore}") { self }

    has_and_belongs_to_many :genres
    has_many :castings, as: 'media'
    has_many :installments, as: 'media'
    has_many :franchises, through: :installments
    has_many :library_entries, as: 'media', dependent: :destroy,
                               inverse_of: :media
    has_many :mappings, as: 'media', dependent: :destroy
    has_many :reviews, as: 'media', dependent: :destroy
    has_many :media_relationships,
      class_name: 'MediaRelationship',
      as: 'source',
      dependent: :destroy
    has_many :inverse_media_relationships,
      class_name: 'MediaRelationship',
      as: 'destination',
      dependent: :destroy
    has_many :favorites, as: 'item', dependent: :destroy,
                         inverse_of: :item
    delegate :year, to: :start_date, allow_nil: true

    validates_attachment :poster_image, content_type: {
      content_type: %w[image/jpg image/jpeg image/png]
    }

    after_commit :setup_feed, on: :create
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

  def status
    return :finished if end_date&.past?
    return :current if start_date&.past?
    return :upcoming if start_date && start_date < Date.today + 3.months
    return :nya if start_date&.future?
  end

  def feed
    @feed ||= MediaFeed.new(self.class.name, id)
  end

  def setup_feed
    feed.setup!
  end
end
