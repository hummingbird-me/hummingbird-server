# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: characters
#
#  id                 :integer          not null, primary key
#  description        :text
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  name               :string(255)
#  primary_media_type :string
#  slug               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  mal_id             :integer          indexed, indexed
#  primary_media_id   :integer
#
# Indexes
#
#  character_mal_id            (mal_id) UNIQUE
#  index_characters_on_mal_id  (mal_id) UNIQUE
#
# rubocop:enable Metrics/LineLength

class Character < ApplicationRecord
  include LocalizableModel
  include Mappable
  include DescriptionSanitation
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders history]

  has_attached_file :image

  validates_attachment :image, content_type: {
    content_type: %w[image/jpg image/jpeg image/png]
  }
  validates :canonical_name, presence: true
  validates :primary_media, polymorphism: { type: Media }, allow_blank: true

  belongs_to :primary_media, polymorphic: true, optional: true
  has_many :castings
  has_many :media_characters, dependent: :destroy
  has_many :anime_characters, dependent: :destroy
  has_many :manga_characters, dependent: :destroy
  has_many :drama_characters, dependent: :destroy

  update_algolia('AlgoliaCharactersIndex')

  def canonical_name
    names[self[:canonical_name]]
  end

  def name=(value)
    names['en'] = value
    self.canonical_name = 'en'
  end

  def slug_candidates
    [
      -> { canonical_name },
      (-> { [primary_media.canonical_title, canonical_name] } if primary_media)
    ].compact
  end
end
