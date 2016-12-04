require 'rails_helper'

RSpec.describe LikedFeedPostsBadge do
  let!(:user) { create(:user) }
  let!(:post) { create(:post, user: user) }

  describe 'rank 1' do
    before { create(:post_like, post: post) }

    it 'show rank, progress, title, description, goal' do
      badge = LikedFeedPostsBadge::Rank1.new(user)
      expect(badge.rank).to eq(1)
      expect(badge.goal).to eq(1)
      expect(badge.progress).to eq(1)
      expect(badge.title).to eq('One of us')
      expect(badge.description).to eq('It\'s official, you\'re in!' \
        ' You received your first like from a member of the community.')
      expect(badge.earned?).to eq(true)
    end

    it 'create bestowment' do
      expect(
        Bestowment.where(badge_id: 'LikedFeedPostsBadge::Rank1').count
      ).to eq(1)
    end
  end

  describe 'rank 2' do
    context 'when post liked 5 times' do
      before { 5.times { create(:post_like, post: post) } }

      it 'show rank, progress, title, description, goal' do
        badge = LikedFeedPostsBadge::Rank2.new(user)
        expect(badge.rank).to eq(2)
        expect(badge.goal).to eq(5)
        expect(badge.progress).to eq(5)
        expect(badge.title).to eq('High Five')
        expect(badge.description).to eq('Give me 5! Your post has' \
          ' received 5 likes. Keep it up!')
        expect(badge.earned?).to eq(true)
      end

      it 'create bestowment' do
        expect(Bestowment.where(
          badge_id: 'LikedFeedPostsBadge::Rank2'
        ).count).to eq(1)
        expect(Bestowment.where(
          badge_id: 'LikedFeedPostsBadge::Rank1'
        ).count).to eq(1)
      end
    end

    context 'when post liked 3 times' do
      before { 3.times { create(:post_like, post: post) } }

      it 'don\'t create bestowment' do
        expect(Bestowment.where(
          badge_id: 'LikedFeedPostsBadge::Rank2'
        ).count).to eq(0)
        expect(Bestowment.where(
          badge_id: 'LikedFeedPostsBadge::Rank1'
        ).count).to eq(1)
      end
    end
  end
end
