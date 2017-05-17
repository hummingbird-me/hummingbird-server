require 'rails_helper'

RSpec.describe GetstreamWebhookService do
  shared_examples_for 'correct action url' do |path|
    it 'should return the frontend url that refer to this action' do
      expect(GetstreamWebhookService.new(request).feed_url)
        .to eq("https://kitsu.io/#{path}")
    end
  end

  describe '#feed_url' do
    context 'follow activity' do
      let(:request) do
        JSON.parse(fixture('getstream_webhook/new_feed_request.json')).first
      end

      it_should_behave_like 'correct action url', 'users/4'
    end

    context 'post activity' do
      let(:request) do
        JSON.parse(fixture('getstream_webhook/new_feed_request.json'))[1]
      end

      it_should_behave_like 'correct action url', 'posts/12'
    end

    context 'comment activity' do
      let(:request) do
        JSON.parse(fixture('getstream_webhook/new_feed_request.json'))[4]
      end

      it_should_behave_like 'correct action url', 'comments/9'
    end

    context 'post like activity' do
      let(:request) do
        JSON.parse(fixture('getstream_webhook/new_feed_request.json'))[2]
      end

      it_should_behave_like 'correct action url', 'posts/12'
    end

    context 'comment like activity' do
      let(:request) do
        JSON.parse(fixture('getstream_webhook/new_feed_request.json'))[3]
      end

      it_should_behave_like 'correct action url', 'comments/5'
    end
  end

  describe '#stringify_activity' do
    context 'follow, post, post_like and comment_like activity' do
      let(:request) do
        JSON.parse(fixture('getstream_webhook/new_feed_request.json'))
      end
      let!(:actor) { FactoryGirl.create(:user, id: 4) }
      let!(:target) { FactoryGirl.create(:user, id: 1) }

      it 'should localize follow activity string' do
        expect(GetstreamWebhookService.new(request.first)
          .stringify_activity[:en])
          .to eq("#{actor.name} followed you.")
      end

      it 'should localize post activity string' do
        expect(GetstreamWebhookService.new(request[1]).stringify_activity[:en])
          .to eq("#{actor.name} mentioned you in a post.")
      end

      it 'should localize post like activity string' do
        expect(GetstreamWebhookService.new(request[2]).stringify_activity[:en])
          .to eq("#{actor.name} liked your post.")
      end

      it 'should localize comment like activity string' do
        expect(GetstreamWebhookService.new(request[3]).stringify_activity[:en])
          .to eq("#{actor.name} liked your comment.")
      end
    end

    context 'comment activity' do
      let(:webhook_req) do
        JSON.parse(fixture('getstream_webhook/post_reply_request.json'))
      end
      let!(:actor) { FactoryGirl.create(:user, id: 4) }
      let!(:target) { FactoryGirl.create(:user, id: 1) }

      context 'when notification feed target and reply to user are same' do
        let(:post_reply) { webhook_req.first }
        let(:comment_reply) { webhook_req[1] }

        it 'should localize reply to post activity string' do
          expect(GetstreamWebhookService.new(post_reply)
            .stringify_activity[:en])
            .to eq("#{actor.name} replied to your post.")
        end

        it 'should localize reply to comment activity string' do
          expect(GetstreamWebhookService.new(comment_reply)
            .stringify_activity[:en])
            .to eq("#{actor.name} replied to your comment.")
        end
      end

      context 'when notification feed target and reply to user are different' do
        let(:post_reply) { webhook_req[2] }
        let(:comment_reply) { webhook_req[3] }

        it 'should localize mentioned in a comment activity string' do
          expect(GetstreamWebhookService.new(post_reply)
            .stringify_activity[:en])
            .to eq("#{actor.name} mentioned you in a comment.")
        end
      end
    end
  end
end
