# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: mappings
#
#  id            :integer          not null, primary key
#  external_site :string           not null, indexed => [external_id, item_type, item_id]
#  item_type     :string           not null, indexed => [external_site, external_id, item_id]
#  created_at    :datetime
#  updated_at    :datetime
#  external_id   :string           not null, indexed => [external_site, item_type, item_id]
#  item_id       :integer          not null, indexed => [external_site, external_id, item_type]
#
# Indexes
#
#  index_mappings_on_external_and_item  (external_site,external_id,item_type,item_id) UNIQUE
#
# rubocop:enable Metrics/LineLength

class Mapping < ApplicationRecord
  belongs_to :item, polymorphic: true, required: true

  validates :external_site, :external_id, presence: true
  # Right now, we want to ensure only one external id per item per site
  validates :item_id, uniqueness: { scope: %i[item_type external_site] }

  def self.lookup(site, id)
    item = find_by(external_site: site, external_id: id).try(:item)
    if !item && block_given?
      item = yield
      create!(external_site: site, external_id: id, item: item)
    end
    item
  end

  def self.guess(type, query)
    return nil unless query[:title]
    type = type.name unless type.is_a?(String)
    filters = []
    filters << "kind:#{type.underscore.dasherize}"
    if query[:episode_count]
      filters << "episodeCount:#{query[:episode_count] - 2} TO #{query[:episode_count] + 2}"
    end

    filters << query[:subtype] if query[:subtype]

    AlgoliaMediaIndex.search(
      query[:title],
      filters: filters.join(' AND ')
    ).first
  end
end
