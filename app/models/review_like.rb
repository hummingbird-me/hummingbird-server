# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: review_likes
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  review_id  :integer          not null, indexed
#  user_id    :integer          not null, indexed
#
# Indexes
#
#  index_review_likes_on_review_id  (review_id)
#  index_review_likes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_2f5b7cb84c  (user_id => users.id)
#  fk_rails_e06d0d2851  (review_id => reviews.id)
#
# rubocop:enable Metrics/LineLength

class ReviewLike < ApplicationRecord
  belongs_to :review, required: true, counter_cache: :likes_count
  belongs_to :user, required: true
end
