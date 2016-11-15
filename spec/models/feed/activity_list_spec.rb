require 'rails_helper'

RSpec.describe Feed::ActivityList, type: :model do
  let(:list) { Feed::ActivityList.new(Feed.new('user', '1')) }
  subject { list }

  describe '#page' do
    context 'with a page number' do
      subject { list.page(1) }
      it 'should set the page_number' do
        expect(subject.page_number).to eq(1)
      end
    end
    context 'with an id_lt' do
      subject { list.page(id_lt: '12345') }
      it 'should set the id_lt on the query' do
        expect(subject.data).to have_key(:id_lt)
      end
    end
  end

  describe '#per' do
    subject { list.per(10) }
    it 'should set the page_size attribute' do
      expect(subject.page_size).to eq(10)
    end
  end

  describe 'combining #per and #page' do
    subject { list.per(10).page(5) }
    it 'should set the offset in the query' do
      expect(subject.data[:offset]).to eq(40)
    end
    it 'should set the limit in the query' do
      expect(subject.data[:limit]).to eq(10)
    end
  end

  describe '#limit' do
    subject { list.limit(20) }
    it 'should set the limit in the query' do
      expect(subject.data[:limit]).to eq(20)
    end
    it 'should not mutate the original instance' do
      expect(list.data[:limit]).to be_nil
    end
  end

  describe '#offset' do
    subject { list.offset(20) }
    it 'should set the offset in the query' do
      expect(subject.data[:offset]).to eq(20)
    end
    it 'should not mutate the original instance' do
      expect(list.data[:offset]).to be_nil
    end
  end

  describe '#ranking' do
    subject { list.ranking('cool_ranking') }
    it 'should set the ranking in the query' do
      expect(subject.data[:ranking]).to eq('cool_ranking')
    end
    it 'should not mutate the original instance' do
      expect(list.data[:ranking]).to be_nil
    end
  end

  describe '#new' do
    it 'should return an Activity with the feed preloaded' do
      expect(subject.new).to be_a(Feed::Activity)
    end
  end

  describe '#add' do
    let(:activity) { Feed::Activity.new(subject) }
    it 'should tell Stream to add the activity by JSON' do
      expect(subject.feed.stream_feed).to receive(:add_activity).with(Hash).once
      subject.add(activity)
    end
  end

  describe '#update' do
    let(:activity) { Feed::Activity.new(subject) }
    before { activity }
    it 'should tell Stream to update the activity by JSON' do
      client = double('Stream::Client')
      allow(Feed).to receive(:client).and_return(client)
      expect(client).to receive(:update_activity).with(Hash).once
      subject.update(activity)
    end
  end

  describe '#destroy' do
    context 'with string foreign_id' do
      let(:activity) { Feed::Activity.new(subject, foreign_id: 'id') }
      it 'should tell Stream to remove the activity by ID' do
        expect(subject.feed.stream_feed).to receive(:remove_activity)
          .with('id', foreign_id: true).once
        subject.destroy(activity)
      end
    end

    context 'with object foreign_id' do
      let(:object) { OpenStruct.new(stream_id: 'id') }
      let(:activity) { Feed::Activity.new(subject, foreign_id: object) }
      it 'should tell Stream to remove the activity by the #stream_id' do
        expect(subject.feed.stream_feed).to receive(:remove_activity)
          .with('id', foreign_id: true).once
        subject.destroy(activity)
      end
    end
  end

  describe '#to_a' do
    subject { list.limit(50) }
    it 'should get the activities using the query and read the results' do
      expect(subject.feed.stream_feed).to receive(:get).with(limit: 50)
        .and_return({'results' => []})
      expect(subject.to_a).to eq([])
    end
    context 'for an aggregated feed' do
      subject { Feed::ActivityList.new(Feed.new('user_aggr', '1')) }
      it 'should return an Array of ActivityGroup instances' do
        expect(subject.feed.stream_feed).to receive(:get).and_return({
          'results' => [
            {
              'activities' => [{}]
            }, {
              'activities' => [{}]
            }
          ]
        })
        expect(subject.to_a).to all(be_a(Feed::ActivityGroup))
      end
    end
    context 'for a flat feed' do
      subject { Feed::ActivityList.new(Feed.new('user', '1')) }
      it 'should return an Array of Activity instances' do
        expect(subject.feed.stream_feed).to receive(:get).and_return({
          'results' => [{}, {}]
        })
        expect(subject.to_a).to all(be_a(Feed::Activity))
      end
    end
  end
end
