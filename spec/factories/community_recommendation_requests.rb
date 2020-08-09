# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: community_recommendation_requests
#
#  id          :integer          not null, primary key
#  description :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null, indexed
#
# Indexes
#
#  index_community_recommendation_requests_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_0a581e110a  (user_id => users.id)
#
# rubocop:enable Metrics/LineLength

FactoryBot.define do
  factory :community_recommendation_request do
    user
    description { { en: Faker::Lorem.sentence } }
    title { Faker::Name.name }
  end
end
