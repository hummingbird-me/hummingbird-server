# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  mal_id             :integer          indexed, indexed
#
# Indexes
#
#  index_people_on_mal_id  (mal_id) UNIQUE
#  person_mal_id           (mal_id) UNIQUE
#
# rubocop:enable Metrics/LineLength

class Person < ApplicationRecord
  include Mappable
  extend FriendlyId
  friendly_id :name, use: %i[slugged finders history]
  has_attached_file :image

  has_many :castings, dependent: :destroy
  has_many :anime_castings, dependent: :destroy
  has_many :drama_castings, dependent: :destroy
  has_many :staff, class_name: 'MediaStaff', dependent: :destroy
  has_many :voices, class_name: 'CharacterVoice', dependent: :destroy

  validates_attachment :image, content_type: {
    content_type: %w[image/jpg image/jpeg image/png]
  }
  validates :name, presence: true
end
