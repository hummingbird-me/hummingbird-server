# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: media_reaction_votes
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  media_reaction_id :integer          indexed, indexed => [user_id]
#  user_id           :integer          indexed => [media_reaction_id], indexed
#
# Indexes
#
#  index_media_reaction_votes_on_media_reaction_id              (media_reaction_id)
#  index_media_reaction_votes_on_media_reaction_id_and_user_id  (media_reaction_id,user_id) UNIQUE
#  index_media_reaction_votes_on_user_id                        (user_id)
#
# Foreign Keys
#
#  fk_rails_4d07eecb67  (user_id => users.id)
#  fk_rails_dab3468b92  (media_reaction_id => media_reactions.id)
#
# rubocop:enable Metrics/LineLength

class MediaReactionVote < ActiveRecord::Base
  belongs_to :media_reaction, required: true, counter_cache: :up_votes_count
  belongs_to :user, required: true

  validate :vote_on_self

  def vote_on_self
    if media_reaction.user == user
      errors.add(:user, 'You can not vote for yourself')
    end
  end
end
