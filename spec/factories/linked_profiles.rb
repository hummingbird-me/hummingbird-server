# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: linked_profiles
#
#  id               :integer          not null, primary key
#  private          :boolean          default(TRUE), not null
#  share_from       :boolean          default(FALSE), not null
#  share_to         :boolean          default(FALSE), not null
#  token            :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  external_user_id :string           not null
#  linked_site_id   :integer          not null, indexed
#  user_id          :integer          not null, indexed
#
# Indexes
#
#  index_linked_profiles_on_linked_site_id  (linked_site_id)
#  index_linked_profiles_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_166e103170  (user_id => users.id)
#  fk_rails_25de88e967  (linked_site_id => linked_sites.id)
#
# rubocop:enable Metrics/LineLength

FactoryGirl.define do
  factory :linked_profile do
    user
    linked_site
    url { Faker::Internet.url }
    external_user_id { Faker::Internet.user_name }
  end
end
