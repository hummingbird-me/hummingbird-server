# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: streamers
#
#  id                :integer          not null, primary key
#  logo_content_type :string
#  logo_file_name    :string
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  site_name         :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#
# rubocop:enable Metrics/LineLength

class Streamer < ApplicationRecord
  has_attached_file :logo
  has_many :streaming_links

  validates :site_name, presence: true
  validates_attachment :logo, content_type: {
    content_type: %w[image/png]
  }

  def self.find_by_name(name)
    Streamer.where('lower(site_name) = ?', name.downcase).first
  end
end
