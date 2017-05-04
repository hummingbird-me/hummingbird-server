class WebhooksController < ApplicationController
  include CustomControllerHelpers

  before_action :check_linked_account_param, except: :getstream_firehose

  def youtube_verify
    mode = params['hub.mode']
    topic = params['hub.topic']
    challenge = params['hub.challenge']

    if !linked_account && mode == 'unsubscribe' # deleted linked-account
      render text: challenge
    elsif linked_account && mode == 'subscribe' # created linked-account
      return head status: 404 unless topic == linked_account.topic_url
      render text: challenge
    else
      head status: 404
    end
  end

  def youtube_notify
    signature = request.headers['X-Hub-Signature'].split('sha1=').last
    body = request.body.read
    match = YoutubeService::Subscription.hmac_matches?(body, signature)

    if match && linked_account.share_from?
      YoutubeService::Notification.new(body).post!(linked_account.user)
    end

    head status: 200
  end

  def getstream_firehose
    notifications = JSON.parse(request.body.read)
    list = FeedQueryService.new({
      group: 'notifications',
      id: 5,
      }, nil).list
    puts FeedSerializerService.new(
      list,
      including: ['actor', 'target.post'],
      context: context,
      base_url: request.url
    ).to_json
    notifications.each do |notification|
      # OneSignalNotificationWorker.perform_async(notification) if notification['new'].length > 0 
    end

    head status: 200
  end

  private

  def linked_account
    @linked_account ||= LinkedAccount::YoutubeChannel.find_by(
      id: params[:linked_account]
    )
  end

  def check_linked_account_param
    unless params.include? :linked_account
      render status: 400, text: 'Missing linked_account'
    end
  end
end
