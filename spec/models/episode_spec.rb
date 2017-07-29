# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: episodes
#
#  id                     :integer          not null, primary key
#  absolute_number        :integer
#  airdate                :date
#  canonical_title        :string           default("en_jp"), not null
#  length                 :integer
#  media_type             :string           not null, indexed => [media_id]
#  number                 :integer
#  season_number          :integer
#  synopsis               :text
#  thumbnail_content_type :string(255)
#  thumbnail_file_name    :string(255)
#  thumbnail_file_size    :integer
#  thumbnail_updated_at   :datetime
#  titles                 :hstore           default({}), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  media_id               :integer          not null, indexed => [media_type]
#
# Indexes
#
#  index_episodes_on_media_type_and_media_id  (media_type,media_id)
#
# rubocop:enable Metrics/LineLength

require 'rails_helper'

RSpec.describe Episode, type: :model do
  subject { create(:episode, media: anime) }
  let(:anime) { create(:anime) }

  it { should validate_presence_of(:media) }
  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:season_number) }
  it 'should strip XSS from synopsis' do
    subject.synopsis = '<script>prompt("PASSWORD:")</script>' * 3
    subject.save!
    expect(subject.synopsis).not_to include('<script>')
  end
  context 'triggers recalculation of episode length on anime' do
    it 'after destroy' do
      episode = create(:episode, media: anime)
      expect(anime).to receive(:recalculate_episode_length!)
      episode.destroy!
    end
    it 'when length changed' do
      episode = create(:episode, media: anime, length: rand(10..40))
      expect(anime).to receive(:recalculate_episode_length!)
      episode.length = rand(50..100)
      episode.save!
    end
  end
  it 'should default length to the anime episode length' do
    length = rand(10..60)
    allow(anime).to receive(:episode_length) { length }
    episode = create(:episode, media: anime, length: nil)
    expect(episode.length).to eq(length)
  end
  describe '::length_mode' do
    before do
      10.times { create(:episode, media: anime, length: 10) }
      2.times { create(:episode, media: anime, length: 20) }
    end
    it 'should return a hash of mode and count' do
      mode = anime.episodes.length_mode
      expect(mode).to be_a(Hash)
      expect(mode).to include(:mode)
      expect(mode).to include(:count)
    end
    it 'should return the correct mode' do
      mode = anime.episodes.length_mode
      expect(mode[:mode]).to eq(10)
      expect(mode[:count]).to eq(10)
    end
  end
  describe '::length_average' do
    before do
      10.times { create(:episode, media: anime, length: 10) }
      10.times { create(:episode, media: anime, length: 20) }
    end
    it 'should return the correct average' do
      average = anime.episodes.length_average
      expect(average).to eq(15)
    end
  end
end
