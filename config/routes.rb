# rubocop:disable Metrics/BlockLength
require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  scope '/api' do
    scope '/edge' do
      ### Users
      jsonapi_resources :users
      post '/users/_recover', to: 'users#recover'
      # Profile data
      jsonapi_resources :profile_links
      jsonapi_resources :profile_link_sites
      # Follows/Blocks/Memberships
      jsonapi_resources :follows do
        post :import_from_facebook, on: :collection
        post :import_from_twitter, on: :collection
      end
      jsonapi_resources :media_follows
      jsonapi_resources :post_follows
      jsonapi_resources :blocks
      # Imports & Linked Accounts
      jsonapi_resources :linked_accounts
      jsonapi_resources :list_imports
      jsonapi_resources :library_entry_logs
      # Permissions
      jsonapi_resources :user_roles
      jsonapi_resources :roles

      ### Library
      jsonapi_resources :library_entries
      jsonapi_resources :favorites

      ### Media
      jsonapi_resources :anime
      jsonapi_resources :manga
      jsonapi_resources :drama
      # Cast Info
      jsonapi_resources :anime_characters
      jsonapi_resources :anime_castings
      jsonapi_resources :anime_staff
      jsonapi_resources :drama_characters
      jsonapi_resources :drama_castings
      jsonapi_resources :drama_staff
      jsonapi_resources :manga_characters
      jsonapi_resources :manga_staff
      # Other Info
      jsonapi_resources :mappings
      jsonapi_resources :genres
      jsonapi_resources :streaming_links
      jsonapi_resources :streamers
      jsonapi_resources :media_relationships
      jsonapi_resources :anime_productions
      jsonapi_resources :episodes
      jsonapi_resources :stats
      # DEPRECATED: Legacy systems
      jsonapi_resources :castings
      get '/anime/:anime_id/_languages', to: 'anime#languages'
      jsonapi_resources :franchises
      jsonapi_resources :installments
      # Reviews
      jsonapi_resources :reviews
      jsonapi_resources :review_likes
      # Trending
      get '/trending/:namespace', to: 'trending#index'

      ### People/Characters/Companies
      jsonapi_resources :characters
      jsonapi_resources :people
      jsonapi_resources :producers

      ### Feeds
      jsonapi_resources :posts
      jsonapi_resources :post_likes
      jsonapi_resources :comments
      jsonapi_resources :comment_likes
      jsonapi_resources :reports
      resources :activities, only: %i[destroy]
      get '/feeds/:group/:id', to: 'feeds#show'
      post '/feeds/:group/:id/_read', to: 'feeds#mark_read'
      post '/feeds/:group/:id/_seen', to: 'feeds#mark_seen'
      delete '/feeds/:group/:id/activities/:uuid', to: 'feeds#destroy_activity'

      ### Site Announcements
      jsonapi_resources :site_announcements

      ### Groups
      jsonapi_resources :groups
      jsonapi_resources :group_members
      jsonapi_resources :group_permissions
      jsonapi_resources :group_neighbors
      jsonapi_resources :group_categories
      # Tickets
      jsonapi_resources :group_tickets
      jsonapi_resources :group_ticket_messages
      # Moderation
      jsonapi_resources :group_reports
      jsonapi_resources :group_bans
      jsonapi_resources :group_member_notes
      # Leader Chat
      jsonapi_resources :leader_chat_messages
      # Action logs
      jsonapi_resources :group_action_logs
      # Invites
      jsonapi_resources :group_invites
      post '/group-invites/:id/_accept', to: 'group_invites#accept'
      post '/group-invites/:id/_decline', to: 'group_invites#decline'
      post '/group-invites/:id/_revoke', to: 'group_invites#revoke'
      get '/groups/:id/_stats', to: 'groups#stats'
      post '/groups/:id/_read', to: 'groups#read'
      # Integrations
      get '/sso/canny', to: 'sso#canny'
    end

    ### Admin Panel
    constraints(AdminConstraint) do
      mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
      mount Sidekiq::Web => '/sidekiq'
    end
    get '/admin', to: 'sessions#redirect'
    get '/sidekiq', to: 'sessions#redirect'
    resources :sessions, only: %i[new create]

    ### Debug APIs
    get '/debug/dump_all', to: 'debug#dump_all'
    post '/debug/trace_on', to: 'debug#trace_on'
    get '/debug/gc_info', to: 'debug#gc_info'

    ### WebHooks
    get '/hooks/youtube', to: 'webhooks#youtube_verify'
    post '/hooks/youtube', to: 'webhooks#youtube_notify'
    post '/hooks/getstream', to: 'webhooks#getstream_firehose'

    ### Staging Sync
    post '/user/_prodsync', to: 'users#prod_sync'

    ### Authentication
    use_doorkeeper

    root to: 'home#index'
  end
end


# == Route Map
#
# I, [2017-04-28T00:33:17.625572 #36485]  INFO -- : Raven 2.4.0 configured not to capture errors: DSN not set
#                                          Prefix Verb      URI Pattern                                                                               Controller#Action
#                        user_relationships_waifu GET       /api/edge/users/:user_id/relationships/waifu(.:format)                                    users#show_relationship {:relationship=>"waifu"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/waifu(.:format)                                    users#update_relationship {:relationship=>"waifu"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/waifu(.:format)                                    users#destroy_relationship {:relationship=>"waifu"}
#                                      user_waifu GET       /api/edge/users/:user_id/waifu(.:format)                                                  characters#get_related_resource {:relationship=>"waifu", :source=>"users"}
#                  user_relationships_pinned_post GET       /api/edge/users/:user_id/relationships/pinned-post(.:format)                              users#show_relationship {:relationship=>"pinned_post"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/pinned-post(.:format)                              users#update_relationship {:relationship=>"pinned_post"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/pinned-post(.:format)                              users#destroy_relationship {:relationship=>"pinned_post"}
#                                user_pinned_post GET       /api/edge/users/:user_id/pinned-post(.:format)                                            posts#get_related_resource {:relationship=>"pinned_post", :source=>"users"}
#                    user_relationships_followers GET       /api/edge/users/:user_id/relationships/followers(.:format)                                users#show_relationship {:relationship=>"followers"}
#                                                 POST      /api/edge/users/:user_id/relationships/followers(.:format)                                users#create_relationship {:relationship=>"followers"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/followers(.:format)                                users#update_relationship {:relationship=>"followers"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/followers(.:format)                                users#destroy_relationship {:relationship=>"followers"}
#                                  user_followers GET       /api/edge/users/:user_id/followers(.:format)                                              follows#get_related_resources {:relationship=>"followers", :source=>"users"}
#                    user_relationships_following GET       /api/edge/users/:user_id/relationships/following(.:format)                                users#show_relationship {:relationship=>"following"}
#                                                 POST      /api/edge/users/:user_id/relationships/following(.:format)                                users#create_relationship {:relationship=>"following"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/following(.:format)                                users#update_relationship {:relationship=>"following"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/following(.:format)                                users#destroy_relationship {:relationship=>"following"}
#                                  user_following GET       /api/edge/users/:user_id/following(.:format)                                              follows#get_related_resources {:relationship=>"following", :source=>"users"}
#                       user_relationships_blocks GET       /api/edge/users/:user_id/relationships/blocks(.:format)                                   users#show_relationship {:relationship=>"blocks"}
#                                                 POST      /api/edge/users/:user_id/relationships/blocks(.:format)                                   users#create_relationship {:relationship=>"blocks"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/blocks(.:format)                                   users#update_relationship {:relationship=>"blocks"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/blocks(.:format)                                   users#destroy_relationship {:relationship=>"blocks"}
#                                     user_blocks GET       /api/edge/users/:user_id/blocks(.:format)                                                 blocks#get_related_resources {:relationship=>"blocks", :source=>"users"}
#              user_relationships_linked_accounts GET       /api/edge/users/:user_id/relationships/linked-accounts(.:format)                          users#show_relationship {:relationship=>"linked_accounts"}
#                                                 POST      /api/edge/users/:user_id/relationships/linked-accounts(.:format)                          users#create_relationship {:relationship=>"linked_accounts"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/linked-accounts(.:format)                          users#update_relationship {:relationship=>"linked_accounts"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/linked-accounts(.:format)                          users#destroy_relationship {:relationship=>"linked_accounts"}
#                            user_linked_accounts GET       /api/edge/users/:user_id/linked-accounts(.:format)                                        linked_accounts#get_related_resources {:relationship=>"linked_accounts", :source=>"users"}
#                user_relationships_profile_links GET       /api/edge/users/:user_id/relationships/profile-links(.:format)                            users#show_relationship {:relationship=>"profile_links"}
#                                                 POST      /api/edge/users/:user_id/relationships/profile-links(.:format)                            users#create_relationship {:relationship=>"profile_links"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/profile-links(.:format)                            users#update_relationship {:relationship=>"profile_links"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/profile-links(.:format)                            users#destroy_relationship {:relationship=>"profile_links"}
#                              user_profile_links GET       /api/edge/users/:user_id/profile-links(.:format)                                          profile_links#get_related_resources {:relationship=>"profile_links", :source=>"users"}
#                user_relationships_media_follows GET       /api/edge/users/:user_id/relationships/media-follows(.:format)                            users#show_relationship {:relationship=>"media_follows"}
#                                                 POST      /api/edge/users/:user_id/relationships/media-follows(.:format)                            users#create_relationship {:relationship=>"media_follows"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/media-follows(.:format)                            users#update_relationship {:relationship=>"media_follows"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/media-follows(.:format)                            users#destroy_relationship {:relationship=>"media_follows"}
#                              user_media_follows GET       /api/edge/users/:user_id/media-follows(.:format)                                          media_follows#get_related_resources {:relationship=>"media_follows", :source=>"users"}
#                   user_relationships_user_roles GET       /api/edge/users/:user_id/relationships/user-roles(.:format)                               users#show_relationship {:relationship=>"user_roles"}
#                                                 POST      /api/edge/users/:user_id/relationships/user-roles(.:format)                               users#create_relationship {:relationship=>"user_roles"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/user-roles(.:format)                               users#update_relationship {:relationship=>"user_roles"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/user-roles(.:format)                               users#destroy_relationship {:relationship=>"user_roles"}
#                                 user_user_roles GET       /api/edge/users/:user_id/user-roles(.:format)                                             user_roles#get_related_resources {:relationship=>"user_roles", :source=>"users"}
#              user_relationships_library_entries GET       /api/edge/users/:user_id/relationships/library-entries(.:format)                          users#show_relationship {:relationship=>"library_entries"}
#                                                 POST      /api/edge/users/:user_id/relationships/library-entries(.:format)                          users#create_relationship {:relationship=>"library_entries"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/library-entries(.:format)                          users#update_relationship {:relationship=>"library_entries"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/library-entries(.:format)                          users#destroy_relationship {:relationship=>"library_entries"}
#                            user_library_entries GET       /api/edge/users/:user_id/library-entries(.:format)                                        library_entries#get_related_resources {:relationship=>"library_entries", :source=>"users"}
#                    user_relationships_favorites GET       /api/edge/users/:user_id/relationships/favorites(.:format)                                users#show_relationship {:relationship=>"favorites"}
#                                                 POST      /api/edge/users/:user_id/relationships/favorites(.:format)                                users#create_relationship {:relationship=>"favorites"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/favorites(.:format)                                users#update_relationship {:relationship=>"favorites"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/favorites(.:format)                                users#destroy_relationship {:relationship=>"favorites"}
#                                  user_favorites GET       /api/edge/users/:user_id/favorites(.:format)                                              favorites#get_related_resources {:relationship=>"favorites", :source=>"users"}
#                      user_relationships_reviews GET       /api/edge/users/:user_id/relationships/reviews(.:format)                                  users#show_relationship {:relationship=>"reviews"}
#                                                 POST      /api/edge/users/:user_id/relationships/reviews(.:format)                                  users#create_relationship {:relationship=>"reviews"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/reviews(.:format)                                  users#update_relationship {:relationship=>"reviews"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/reviews(.:format)                                  users#destroy_relationship {:relationship=>"reviews"}
#                                    user_reviews GET       /api/edge/users/:user_id/reviews(.:format)                                                reviews#get_related_resources {:relationship=>"reviews", :source=>"users"}
#                        user_relationships_stats GET       /api/edge/users/:user_id/relationships/stats(.:format)                                    users#show_relationship {:relationship=>"stats"}
#                                                 POST      /api/edge/users/:user_id/relationships/stats(.:format)                                    users#create_relationship {:relationship=>"stats"}
#                                                 PUT|PATCH /api/edge/users/:user_id/relationships/stats(.:format)                                    users#update_relationship {:relationship=>"stats"}
#                                                 DELETE    /api/edge/users/:user_id/relationships/stats(.:format)                                    users#destroy_relationship {:relationship=>"stats"}
#                                      user_stats GET       /api/edge/users/:user_id/stats(.:format)                                                  stats#get_related_resources {:relationship=>"stats", :source=>"users"}
#                                           users GET       /api/edge/users(.:format)                                                                 users#index
#                                                 POST      /api/edge/users(.:format)                                                                 users#create
#                                            user GET       /api/edge/users/:id(.:format)                                                             users#show
#                                                 PATCH     /api/edge/users/:id(.:format)                                                             users#update
#                                                 PUT       /api/edge/users/:id(.:format)                                                             users#update
#                                                 DELETE    /api/edge/users/:id(.:format)                                                             users#destroy
#                                  users__recover POST      /api/edge/users/_recover(.:format)                                                        users#recover
#                 profile_link_relationships_user GET       /api/edge/profile-links/:profile_link_id/relationships/user(.:format)                     profile_links#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/profile-links/:profile_link_id/relationships/user(.:format)                     profile_links#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/profile-links/:profile_link_id/relationships/user(.:format)                     profile_links#destroy_relationship {:relationship=>"user"}
#                               profile_link_user GET       /api/edge/profile-links/:profile_link_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"profile_links"}
#    profile_link_relationships_profile_link_site GET       /api/edge/profile-links/:profile_link_id/relationships/profile-link-site(.:format)        profile_links#show_relationship {:relationship=>"profile_link_site"}
#                                                 PUT|PATCH /api/edge/profile-links/:profile_link_id/relationships/profile-link-site(.:format)        profile_links#update_relationship {:relationship=>"profile_link_site"}
#                                                 DELETE    /api/edge/profile-links/:profile_link_id/relationships/profile-link-site(.:format)        profile_links#destroy_relationship {:relationship=>"profile_link_site"}
#                  profile_link_profile_link_site GET       /api/edge/profile-links/:profile_link_id/profile-link-site(.:format)                      profile_link_sites#get_related_resource {:relationship=>"profile_link_site", :source=>"profile_links"}
#                                   profile_links GET       /api/edge/profile-links(.:format)                                                         profile_links#index
#                                                 POST      /api/edge/profile-links(.:format)                                                         profile_links#create
#                                    profile_link GET       /api/edge/profile-links/:id(.:format)                                                     profile_links#show
#                                                 PATCH     /api/edge/profile-links/:id(.:format)                                                     profile_links#update
#                                                 PUT       /api/edge/profile-links/:id(.:format)                                                     profile_links#update
#                                                 DELETE    /api/edge/profile-links/:id(.:format)                                                     profile_links#destroy
#                              profile_link_sites GET       /api/edge/profile-link-sites(.:format)                                                    profile_link_sites#index
#                               profile_link_site GET       /api/edge/profile-link-sites/:id(.:format)                                                profile_link_sites#show
#                    import_from_facebook_follows POST      /api/edge/follows/import_from_facebook(.:format)                                          follows#import_from_facebook
#                     import_from_twitter_follows POST      /api/edge/follows/import_from_twitter(.:format)                                           follows#import_from_twitter
#                                         follows GET       /api/edge/follows(.:format)                                                               follows#index
#                                                 POST      /api/edge/follows(.:format)                                                               follows#create
#                                          follow GET       /api/edge/follows/:id(.:format)                                                           follows#show
#                                                 PATCH     /api/edge/follows/:id(.:format)                                                           follows#update
#                                                 PUT       /api/edge/follows/:id(.:format)                                                           follows#update
#                                                 DELETE    /api/edge/follows/:id(.:format)                                                           follows#destroy
#                 media_follow_relationships_user GET       /api/edge/media-follows/:media_follow_id/relationships/user(.:format)                     media_follows#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/media-follows/:media_follow_id/relationships/user(.:format)                     media_follows#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/media-follows/:media_follow_id/relationships/user(.:format)                     media_follows#destroy_relationship {:relationship=>"user"}
#                               media_follow_user GET       /api/edge/media-follows/:media_follow_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"media_follows"}
#                media_follow_relationships_media GET       /api/edge/media-follows/:media_follow_id/relationships/media(.:format)                    media_follows#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/media-follows/:media_follow_id/relationships/media(.:format)                    media_follows#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/media-follows/:media_follow_id/relationships/media(.:format)                    media_follows#destroy_relationship {:relationship=>"media"}
#                              media_follow_media GET       /api/edge/media-follows/:media_follow_id/media(.:format)                                  media#get_related_resource {:relationship=>"media", :source=>"media_follows"}
#                                   media_follows GET       /api/edge/media-follows(.:format)                                                         media_follows#index
#                                                 POST      /api/edge/media-follows(.:format)                                                         media_follows#create
#                                    media_follow GET       /api/edge/media-follows/:id(.:format)                                                     media_follows#show
#                                                 PATCH     /api/edge/media-follows/:id(.:format)                                                     media_follows#update
#                                                 PUT       /api/edge/media-follows/:id(.:format)                                                     media_follows#update
#                                                 DELETE    /api/edge/media-follows/:id(.:format)                                                     media_follows#destroy
#                  post_follow_relationships_post GET       /api/edge/post-follows/:post_follow_id/relationships/post(.:format)                       post_follows#show_relationship {:relationship=>"post"}
#                                                 PUT|PATCH /api/edge/post-follows/:post_follow_id/relationships/post(.:format)                       post_follows#update_relationship {:relationship=>"post"}
#                                                 DELETE    /api/edge/post-follows/:post_follow_id/relationships/post(.:format)                       post_follows#destroy_relationship {:relationship=>"post"}
#                                post_follow_post GET       /api/edge/post-follows/:post_follow_id/post(.:format)                                     posts#get_related_resource {:relationship=>"post", :source=>"post_follows"}
#                  post_follow_relationships_user GET       /api/edge/post-follows/:post_follow_id/relationships/user(.:format)                       post_follows#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/post-follows/:post_follow_id/relationships/user(.:format)                       post_follows#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/post-follows/:post_follow_id/relationships/user(.:format)                       post_follows#destroy_relationship {:relationship=>"user"}
#                                post_follow_user GET       /api/edge/post-follows/:post_follow_id/user(.:format)                                     users#get_related_resource {:relationship=>"user", :source=>"post_follows"}
#                                    post_follows GET       /api/edge/post-follows(.:format)                                                          post_follows#index
#                                                 POST      /api/edge/post-follows(.:format)                                                          post_follows#create
#                                     post_follow GET       /api/edge/post-follows/:id(.:format)                                                      post_follows#show
#                                                 PATCH     /api/edge/post-follows/:id(.:format)                                                      post_follows#update
#                                                 PUT       /api/edge/post-follows/:id(.:format)                                                      post_follows#update
#                                                 DELETE    /api/edge/post-follows/:id(.:format)                                                      post_follows#destroy
#                        block_relationships_user GET       /api/edge/blocks/:block_id/relationships/user(.:format)                                   blocks#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/blocks/:block_id/relationships/user(.:format)                                   blocks#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/blocks/:block_id/relationships/user(.:format)                                   blocks#destroy_relationship {:relationship=>"user"}
#                                      block_user GET       /api/edge/blocks/:block_id/user(.:format)                                                 users#get_related_resource {:relationship=>"user", :source=>"blocks"}
#                     block_relationships_blocked GET       /api/edge/blocks/:block_id/relationships/blocked(.:format)                                blocks#show_relationship {:relationship=>"blocked"}
#                                                 PUT|PATCH /api/edge/blocks/:block_id/relationships/blocked(.:format)                                blocks#update_relationship {:relationship=>"blocked"}
#                                                 DELETE    /api/edge/blocks/:block_id/relationships/blocked(.:format)                                blocks#destroy_relationship {:relationship=>"blocked"}
#                                   block_blocked GET       /api/edge/blocks/:block_id/blocked(.:format)                                              users#get_related_resource {:relationship=>"blocked", :source=>"blocks"}
#                                          blocks GET       /api/edge/blocks(.:format)                                                                blocks#index
#                                                 POST      /api/edge/blocks(.:format)                                                                blocks#create
#                                           block GET       /api/edge/blocks/:id(.:format)                                                            blocks#show
#                                                 PATCH     /api/edge/blocks/:id(.:format)                                                            blocks#update
#                                                 PUT       /api/edge/blocks/:id(.:format)                                                            blocks#update
#                                                 DELETE    /api/edge/blocks/:id(.:format)                                                            blocks#destroy
#               linked_account_relationships_user GET       /api/edge/linked-accounts/:linked_account_id/relationships/user(.:format)                 linked_accounts#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/linked-accounts/:linked_account_id/relationships/user(.:format)                 linked_accounts#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/linked-accounts/:linked_account_id/relationships/user(.:format)                 linked_accounts#destroy_relationship {:relationship=>"user"}
#                             linked_account_user GET       /api/edge/linked-accounts/:linked_account_id/user(.:format)                               users#get_related_resource {:relationship=>"user", :source=>"linked_accounts"}
# linked_account_relationships_library_entry_logs GET       /api/edge/linked-accounts/:linked_account_id/relationships/library-entry-logs(.:format)   linked_accounts#show_relationship {:relationship=>"library_entry_logs"}
#                                                 POST      /api/edge/linked-accounts/:linked_account_id/relationships/library-entry-logs(.:format)   linked_accounts#create_relationship {:relationship=>"library_entry_logs"}
#                                                 PUT|PATCH /api/edge/linked-accounts/:linked_account_id/relationships/library-entry-logs(.:format)   linked_accounts#update_relationship {:relationship=>"library_entry_logs"}
#                                                 DELETE    /api/edge/linked-accounts/:linked_account_id/relationships/library-entry-logs(.:format)   linked_accounts#destroy_relationship {:relationship=>"library_entry_logs"}
#               linked_account_library_entry_logs GET       /api/edge/linked-accounts/:linked_account_id/library-entry-logs(.:format)                 library_entry_logs#get_related_resources {:relationship=>"library_entry_logs", :source=>"linked_accounts"}
#                                 linked_accounts GET       /api/edge/linked-accounts(.:format)                                                       linked_accounts#index
#                                                 POST      /api/edge/linked-accounts(.:format)                                                       linked_accounts#create
#                                  linked_account GET       /api/edge/linked-accounts/:id(.:format)                                                   linked_accounts#show
#                                                 PATCH     /api/edge/linked-accounts/:id(.:format)                                                   linked_accounts#update
#                                                 PUT       /api/edge/linked-accounts/:id(.:format)                                                   linked_accounts#update
#                                                 DELETE    /api/edge/linked-accounts/:id(.:format)                                                   linked_accounts#destroy
#                  list_import_relationships_user GET       /api/edge/list-imports/:list_import_id/relationships/user(.:format)                       list_imports#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/list-imports/:list_import_id/relationships/user(.:format)                       list_imports#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/list-imports/:list_import_id/relationships/user(.:format)                       list_imports#destroy_relationship {:relationship=>"user"}
#                                list_import_user GET       /api/edge/list-imports/:list_import_id/user(.:format)                                     users#get_related_resource {:relationship=>"user", :source=>"list_imports"}
#                                    list_imports GET       /api/edge/list-imports(.:format)                                                          list_imports#index
#                                                 POST      /api/edge/list-imports(.:format)                                                          list_imports#create
#                                     list_import GET       /api/edge/list-imports/:id(.:format)                                                      list_imports#show
#                                                 PATCH     /api/edge/list-imports/:id(.:format)                                                      list_imports#update
#                                                 PUT       /api/edge/list-imports/:id(.:format)                                                      list_imports#update
#                                                 DELETE    /api/edge/list-imports/:id(.:format)                                                      list_imports#destroy
#  library_entry_log_relationships_linked_account GET       /api/edge/library-entry-logs/:library_entry_log_id/relationships/linked-account(.:format) library_entry_logs#show_relationship {:relationship=>"linked_account"}
#                library_entry_log_linked_account GET       /api/edge/library-entry-logs/:library_entry_log_id/linked-account(.:format)               linked_accounts#get_related_resource {:relationship=>"linked_account", :source=>"library_entry_logs"}
#           library_entry_log_relationships_media GET       /api/edge/library-entry-logs/:library_entry_log_id/relationships/media(.:format)          library_entry_logs#show_relationship {:relationship=>"media"}
#                         library_entry_log_media GET       /api/edge/library-entry-logs/:library_entry_log_id/media(.:format)                        media#get_related_resource {:relationship=>"media", :source=>"library_entry_logs"}
#                              library_entry_logs GET       /api/edge/library-entry-logs(.:format)                                                    library_entry_logs#index
#                               library_entry_log GET       /api/edge/library-entry-logs/:id(.:format)                                                library_entry_logs#show
#                    user_role_relationships_user GET       /api/edge/user-roles/:user_role_id/relationships/user(.:format)                           user_roles#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/user-roles/:user_role_id/relationships/user(.:format)                           user_roles#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/user-roles/:user_role_id/relationships/user(.:format)                           user_roles#destroy_relationship {:relationship=>"user"}
#                                  user_role_user GET       /api/edge/user-roles/:user_role_id/user(.:format)                                         users#get_related_resource {:relationship=>"user", :source=>"user_roles"}
#                    user_role_relationships_role GET       /api/edge/user-roles/:user_role_id/relationships/role(.:format)                           user_roles#show_relationship {:relationship=>"role"}
#                                                 PUT|PATCH /api/edge/user-roles/:user_role_id/relationships/role(.:format)                           user_roles#update_relationship {:relationship=>"role"}
#                                                 DELETE    /api/edge/user-roles/:user_role_id/relationships/role(.:format)                           user_roles#destroy_relationship {:relationship=>"role"}
#                                  user_role_role GET       /api/edge/user-roles/:user_role_id/role(.:format)                                         roles#get_related_resource {:relationship=>"role", :source=>"user_roles"}
#                                      user_roles GET       /api/edge/user-roles(.:format)                                                            user_roles#index
#                                                 POST      /api/edge/user-roles(.:format)                                                            user_roles#create
#                                       user_role GET       /api/edge/user-roles/:id(.:format)                                                        user_roles#show
#                                                 PATCH     /api/edge/user-roles/:id(.:format)                                                        user_roles#update
#                                                 PUT       /api/edge/user-roles/:id(.:format)                                                        user_roles#update
#                                                 DELETE    /api/edge/user-roles/:id(.:format)                                                        user_roles#destroy
#                   role_relationships_user_roles GET       /api/edge/roles/:role_id/relationships/user-roles(.:format)                               roles#show_relationship {:relationship=>"user_roles"}
#                                                 POST      /api/edge/roles/:role_id/relationships/user-roles(.:format)                               roles#create_relationship {:relationship=>"user_roles"}
#                                                 PUT|PATCH /api/edge/roles/:role_id/relationships/user-roles(.:format)                               roles#update_relationship {:relationship=>"user_roles"}
#                                                 DELETE    /api/edge/roles/:role_id/relationships/user-roles(.:format)                               roles#destroy_relationship {:relationship=>"user_roles"}
#                                 role_user_roles GET       /api/edge/roles/:role_id/user-roles(.:format)                                             user_roles#get_related_resources {:relationship=>"user_roles", :source=>"roles"}
#                     role_relationships_resource GET       /api/edge/roles/:role_id/relationships/resource(.:format)                                 roles#show_relationship {:relationship=>"resource"}
#                                                 PUT|PATCH /api/edge/roles/:role_id/relationships/resource(.:format)                                 roles#update_relationship {:relationship=>"resource"}
#                                                 DELETE    /api/edge/roles/:role_id/relationships/resource(.:format)                                 roles#destroy_relationship {:relationship=>"resource"}
#                                   role_resource GET       /api/edge/roles/:role_id/resource(.:format)                                               resources#get_related_resource {:relationship=>"resource", :source=>"roles"}
#                                           roles GET       /api/edge/roles(.:format)                                                                 roles#index
#                                                 POST      /api/edge/roles(.:format)                                                                 roles#create
#                                            role GET       /api/edge/roles/:id(.:format)                                                             roles#show
#                                                 PATCH     /api/edge/roles/:id(.:format)                                                             roles#update
#                                                 PUT       /api/edge/roles/:id(.:format)                                                             roles#update
#                                                 DELETE    /api/edge/roles/:id(.:format)                                                             roles#destroy
#                library_entry_relationships_user GET       /api/edge/library-entries/:library_entry_id/relationships/user(.:format)                  library_entries#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/user(.:format)                  library_entries#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/user(.:format)                  library_entries#destroy_relationship {:relationship=>"user"}
#                              library_entry_user GET       /api/edge/library-entries/:library_entry_id/user(.:format)                                users#get_related_resource {:relationship=>"user", :source=>"library_entries"}
#               library_entry_relationships_anime GET       /api/edge/library-entries/:library_entry_id/relationships/anime(.:format)                 library_entries#show_relationship {:relationship=>"anime"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/anime(.:format)                 library_entries#update_relationship {:relationship=>"anime"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/anime(.:format)                 library_entries#destroy_relationship {:relationship=>"anime"}
#                             library_entry_anime GET       /api/edge/library-entries/:library_entry_id/anime(.:format)                               anime#get_related_resource {:relationship=>"anime", :source=>"library_entries"}
#               library_entry_relationships_manga GET       /api/edge/library-entries/:library_entry_id/relationships/manga(.:format)                 library_entries#show_relationship {:relationship=>"manga"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/manga(.:format)                 library_entries#update_relationship {:relationship=>"manga"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/manga(.:format)                 library_entries#destroy_relationship {:relationship=>"manga"}
#                             library_entry_manga GET       /api/edge/library-entries/:library_entry_id/manga(.:format)                               manga#get_related_resource {:relationship=>"manga", :source=>"library_entries"}
#               library_entry_relationships_drama GET       /api/edge/library-entries/:library_entry_id/relationships/drama(.:format)                 library_entries#show_relationship {:relationship=>"drama"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/drama(.:format)                 library_entries#update_relationship {:relationship=>"drama"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/drama(.:format)                 library_entries#destroy_relationship {:relationship=>"drama"}
#                             library_entry_drama GET       /api/edge/library-entries/:library_entry_id/drama(.:format)                               dramas#get_related_resource {:relationship=>"drama", :source=>"library_entries"}
#              library_entry_relationships_review GET       /api/edge/library-entries/:library_entry_id/relationships/review(.:format)                library_entries#show_relationship {:relationship=>"review"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/review(.:format)                library_entries#update_relationship {:relationship=>"review"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/review(.:format)                library_entries#destroy_relationship {:relationship=>"review"}
#                            library_entry_review GET       /api/edge/library-entries/:library_entry_id/review(.:format)                              reviews#get_related_resource {:relationship=>"review", :source=>"library_entries"}
#               library_entry_relationships_media GET       /api/edge/library-entries/:library_entry_id/relationships/media(.:format)                 library_entries#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/media(.:format)                 library_entries#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/media(.:format)                 library_entries#destroy_relationship {:relationship=>"media"}
#                             library_entry_media GET       /api/edge/library-entries/:library_entry_id/media(.:format)                               media#get_related_resource {:relationship=>"media", :source=>"library_entries"}
#                library_entry_relationships_unit GET       /api/edge/library-entries/:library_entry_id/relationships/unit(.:format)                  library_entries#show_relationship {:relationship=>"unit"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/unit(.:format)                  library_entries#update_relationship {:relationship=>"unit"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/unit(.:format)                  library_entries#destroy_relationship {:relationship=>"unit"}
#                              library_entry_unit GET       /api/edge/library-entries/:library_entry_id/unit(.:format)                                units#get_related_resource {:relationship=>"unit", :source=>"library_entries"}
#           library_entry_relationships_next_unit GET       /api/edge/library-entries/:library_entry_id/relationships/next-unit(.:format)             library_entries#show_relationship {:relationship=>"next_unit"}
#                                                 PUT|PATCH /api/edge/library-entries/:library_entry_id/relationships/next-unit(.:format)             library_entries#update_relationship {:relationship=>"next_unit"}
#                                                 DELETE    /api/edge/library-entries/:library_entry_id/relationships/next-unit(.:format)             library_entries#destroy_relationship {:relationship=>"next_unit"}
#                         library_entry_next_unit GET       /api/edge/library-entries/:library_entry_id/next-unit(.:format)                           next_units#get_related_resource {:relationship=>"next_unit", :source=>"library_entries"}
#                                 library_entries GET       /api/edge/library-entries(.:format)                                                       library_entries#index
#                                                 POST      /api/edge/library-entries(.:format)                                                       library_entries#create
#                                   library_entry GET       /api/edge/library-entries/:id(.:format)                                                   library_entries#show
#                                                 PATCH     /api/edge/library-entries/:id(.:format)                                                   library_entries#update
#                                                 PUT       /api/edge/library-entries/:id(.:format)                                                   library_entries#update
#                                                 DELETE    /api/edge/library-entries/:id(.:format)                                                   library_entries#destroy
#                     favorite_relationships_user GET       /api/edge/favorites/:favorite_id/relationships/user(.:format)                             favorites#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/favorites/:favorite_id/relationships/user(.:format)                             favorites#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/favorites/:favorite_id/relationships/user(.:format)                             favorites#destroy_relationship {:relationship=>"user"}
#                                   favorite_user GET       /api/edge/favorites/:favorite_id/user(.:format)                                           users#get_related_resource {:relationship=>"user", :source=>"favorites"}
#                     favorite_relationships_item GET       /api/edge/favorites/:favorite_id/relationships/item(.:format)                             favorites#show_relationship {:relationship=>"item"}
#                                                 PUT|PATCH /api/edge/favorites/:favorite_id/relationships/item(.:format)                             favorites#update_relationship {:relationship=>"item"}
#                                                 DELETE    /api/edge/favorites/:favorite_id/relationships/item(.:format)                             favorites#destroy_relationship {:relationship=>"item"}
#                                   favorite_item GET       /api/edge/favorites/:favorite_id/item(.:format)                                           items#get_related_resource {:relationship=>"item", :source=>"favorites"}
#                                       favorites GET       /api/edge/favorites(.:format)                                                             favorites#index
#                                                 POST      /api/edge/favorites(.:format)                                                             favorites#create
#                                        favorite GET       /api/edge/favorites/:id(.:format)                                                         favorites#show
#                                                 PATCH     /api/edge/favorites/:id(.:format)                                                         favorites#update
#                                                 PUT       /api/edge/favorites/:id(.:format)                                                         favorites#update
#                                                 DELETE    /api/edge/favorites/:id(.:format)                                                         favorites#destroy
#                      anime_relationships_genres GET       /api/edge/anime/:anime_id/relationships/genres(.:format)                                  anime#show_relationship {:relationship=>"genres"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/genres(.:format)                                  anime#create_relationship {:relationship=>"genres"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/genres(.:format)                                  anime#update_relationship {:relationship=>"genres"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/genres(.:format)                                  anime#destroy_relationship {:relationship=>"genres"}
#                                    anime_genres GET       /api/edge/anime/:anime_id/genres(.:format)                                                genres#get_related_resources {:relationship=>"genres", :source=>"anime"}
#                    anime_relationships_castings GET       /api/edge/anime/:anime_id/relationships/castings(.:format)                                anime#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/castings(.:format)                                anime#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/castings(.:format)                                anime#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/castings(.:format)                                anime#destroy_relationship {:relationship=>"castings"}
#                                  anime_castings GET       /api/edge/anime/:anime_id/castings(.:format)                                              castings#get_related_resources {:relationship=>"castings", :source=>"anime"}
#                anime_relationships_installments GET       /api/edge/anime/:anime_id/relationships/installments(.:format)                            anime#show_relationship {:relationship=>"installments"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/installments(.:format)                            anime#create_relationship {:relationship=>"installments"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/installments(.:format)                            anime#update_relationship {:relationship=>"installments"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/installments(.:format)                            anime#destroy_relationship {:relationship=>"installments"}
#                              anime_installments GET       /api/edge/anime/:anime_id/installments(.:format)                                          installments#get_related_resources {:relationship=>"installments", :source=>"anime"}
#                    anime_relationships_mappings GET       /api/edge/anime/:anime_id/relationships/mappings(.:format)                                anime#show_relationship {:relationship=>"mappings"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/mappings(.:format)                                anime#create_relationship {:relationship=>"mappings"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/mappings(.:format)                                anime#update_relationship {:relationship=>"mappings"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/mappings(.:format)                                anime#destroy_relationship {:relationship=>"mappings"}
#                                  anime_mappings GET       /api/edge/anime/:anime_id/mappings(.:format)                                              mappings#get_related_resources {:relationship=>"mappings", :source=>"anime"}
#                     anime_relationships_reviews GET       /api/edge/anime/:anime_id/relationships/reviews(.:format)                                 anime#show_relationship {:relationship=>"reviews"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/reviews(.:format)                                 anime#create_relationship {:relationship=>"reviews"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/reviews(.:format)                                 anime#update_relationship {:relationship=>"reviews"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/reviews(.:format)                                 anime#destroy_relationship {:relationship=>"reviews"}
#                                   anime_reviews GET       /api/edge/anime/:anime_id/reviews(.:format)                                               reviews#get_related_resources {:relationship=>"reviews", :source=>"anime"}
#         anime_relationships_media_relationships GET       /api/edge/anime/:anime_id/relationships/media-relationships(.:format)                     anime#show_relationship {:relationship=>"media_relationships"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/media-relationships(.:format)                     anime#create_relationship {:relationship=>"media_relationships"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/media-relationships(.:format)                     anime#update_relationship {:relationship=>"media_relationships"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/media-relationships(.:format)                     anime#destroy_relationship {:relationship=>"media_relationships"}
#                       anime_media_relationships GET       /api/edge/anime/:anime_id/media-relationships(.:format)                                   media_relationships#get_related_resources {:relationship=>"media_relationships", :source=>"anime"}
#                    anime_relationships_episodes GET       /api/edge/anime/:anime_id/relationships/episodes(.:format)                                anime#show_relationship {:relationship=>"episodes"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/episodes(.:format)                                anime#create_relationship {:relationship=>"episodes"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/episodes(.:format)                                anime#update_relationship {:relationship=>"episodes"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/episodes(.:format)                                anime#destroy_relationship {:relationship=>"episodes"}
#                                  anime_episodes GET       /api/edge/anime/:anime_id/episodes(.:format)                                              episodes#get_related_resources {:relationship=>"episodes", :source=>"anime"}
#             anime_relationships_streaming_links GET       /api/edge/anime/:anime_id/relationships/streaming-links(.:format)                         anime#show_relationship {:relationship=>"streaming_links"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/streaming-links(.:format)                         anime#create_relationship {:relationship=>"streaming_links"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/streaming-links(.:format)                         anime#update_relationship {:relationship=>"streaming_links"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/streaming-links(.:format)                         anime#destroy_relationship {:relationship=>"streaming_links"}
#                           anime_streaming_links GET       /api/edge/anime/:anime_id/streaming-links(.:format)                                       streaming_links#get_related_resources {:relationship=>"streaming_links", :source=>"anime"}
#           anime_relationships_anime_productions GET       /api/edge/anime/:anime_id/relationships/anime-productions(.:format)                       anime#show_relationship {:relationship=>"anime_productions"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/anime-productions(.:format)                       anime#create_relationship {:relationship=>"anime_productions"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/anime-productions(.:format)                       anime#update_relationship {:relationship=>"anime_productions"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/anime-productions(.:format)                       anime#destroy_relationship {:relationship=>"anime_productions"}
#                         anime_anime_productions GET       /api/edge/anime/:anime_id/anime-productions(.:format)                                     anime_productions#get_related_resources {:relationship=>"anime_productions", :source=>"anime"}
#            anime_relationships_anime_characters GET       /api/edge/anime/:anime_id/relationships/anime-characters(.:format)                        anime#show_relationship {:relationship=>"anime_characters"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/anime-characters(.:format)                        anime#create_relationship {:relationship=>"anime_characters"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/anime-characters(.:format)                        anime#update_relationship {:relationship=>"anime_characters"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/anime-characters(.:format)                        anime#destroy_relationship {:relationship=>"anime_characters"}
#                          anime_anime_characters GET       /api/edge/anime/:anime_id/anime-characters(.:format)                                      anime_characters#get_related_resources {:relationship=>"anime_characters", :source=>"anime"}
#                 anime_relationships_anime_staff GET       /api/edge/anime/:anime_id/relationships/anime-staff(.:format)                             anime#show_relationship {:relationship=>"anime_staff"}
#                                                 POST      /api/edge/anime/:anime_id/relationships/anime-staff(.:format)                             anime#create_relationship {:relationship=>"anime_staff"}
#                                                 PUT|PATCH /api/edge/anime/:anime_id/relationships/anime-staff(.:format)                             anime#update_relationship {:relationship=>"anime_staff"}
#                                                 DELETE    /api/edge/anime/:anime_id/relationships/anime-staff(.:format)                             anime#destroy_relationship {:relationship=>"anime_staff"}
#                               anime_anime_staff GET       /api/edge/anime/:anime_id/anime-staff(.:format)                                           anime_staff#get_related_resources {:relationship=>"anime_staff", :source=>"anime"}
#                                     anime_index GET       /api/edge/anime(.:format)                                                                 anime#index
#                                                 POST      /api/edge/anime(.:format)                                                                 anime#create
#                                           anime GET       /api/edge/anime/:id(.:format)                                                             anime#show
#                                                 PATCH     /api/edge/anime/:id(.:format)                                                             anime#update
#                                                 PUT       /api/edge/anime/:id(.:format)                                                             anime#update
#                                                 DELETE    /api/edge/anime/:id(.:format)                                                             anime#destroy
#                      manga_relationships_genres GET       /api/edge/manga/:manga_id/relationships/genres(.:format)                                  manga#show_relationship {:relationship=>"genres"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/genres(.:format)                                  manga#create_relationship {:relationship=>"genres"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/genres(.:format)                                  manga#update_relationship {:relationship=>"genres"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/genres(.:format)                                  manga#destroy_relationship {:relationship=>"genres"}
#                                    manga_genres GET       /api/edge/manga/:manga_id/genres(.:format)                                                genres#get_related_resources {:relationship=>"genres", :source=>"manga"}
#                    manga_relationships_castings GET       /api/edge/manga/:manga_id/relationships/castings(.:format)                                manga#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/castings(.:format)                                manga#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/castings(.:format)                                manga#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/castings(.:format)                                manga#destroy_relationship {:relationship=>"castings"}
#                                  manga_castings GET       /api/edge/manga/:manga_id/castings(.:format)                                              castings#get_related_resources {:relationship=>"castings", :source=>"manga"}
#                manga_relationships_installments GET       /api/edge/manga/:manga_id/relationships/installments(.:format)                            manga#show_relationship {:relationship=>"installments"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/installments(.:format)                            manga#create_relationship {:relationship=>"installments"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/installments(.:format)                            manga#update_relationship {:relationship=>"installments"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/installments(.:format)                            manga#destroy_relationship {:relationship=>"installments"}
#                              manga_installments GET       /api/edge/manga/:manga_id/installments(.:format)                                          installments#get_related_resources {:relationship=>"installments", :source=>"manga"}
#                    manga_relationships_mappings GET       /api/edge/manga/:manga_id/relationships/mappings(.:format)                                manga#show_relationship {:relationship=>"mappings"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/mappings(.:format)                                manga#create_relationship {:relationship=>"mappings"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/mappings(.:format)                                manga#update_relationship {:relationship=>"mappings"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/mappings(.:format)                                manga#destroy_relationship {:relationship=>"mappings"}
#                                  manga_mappings GET       /api/edge/manga/:manga_id/mappings(.:format)                                              mappings#get_related_resources {:relationship=>"mappings", :source=>"manga"}
#                     manga_relationships_reviews GET       /api/edge/manga/:manga_id/relationships/reviews(.:format)                                 manga#show_relationship {:relationship=>"reviews"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/reviews(.:format)                                 manga#create_relationship {:relationship=>"reviews"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/reviews(.:format)                                 manga#update_relationship {:relationship=>"reviews"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/reviews(.:format)                                 manga#destroy_relationship {:relationship=>"reviews"}
#                                   manga_reviews GET       /api/edge/manga/:manga_id/reviews(.:format)                                               reviews#get_related_resources {:relationship=>"reviews", :source=>"manga"}
#         manga_relationships_media_relationships GET       /api/edge/manga/:manga_id/relationships/media-relationships(.:format)                     manga#show_relationship {:relationship=>"media_relationships"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/media-relationships(.:format)                     manga#create_relationship {:relationship=>"media_relationships"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/media-relationships(.:format)                     manga#update_relationship {:relationship=>"media_relationships"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/media-relationships(.:format)                     manga#destroy_relationship {:relationship=>"media_relationships"}
#                       manga_media_relationships GET       /api/edge/manga/:manga_id/media-relationships(.:format)                                   media_relationships#get_related_resources {:relationship=>"media_relationships", :source=>"manga"}
#                    manga_relationships_chapters GET       /api/edge/manga/:manga_id/relationships/chapters(.:format)                                manga#show_relationship {:relationship=>"chapters"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/chapters(.:format)                                manga#create_relationship {:relationship=>"chapters"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/chapters(.:format)                                manga#update_relationship {:relationship=>"chapters"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/chapters(.:format)                                manga#destroy_relationship {:relationship=>"chapters"}
#                                  manga_chapters GET       /api/edge/manga/:manga_id/chapters(.:format)                                              chapters#get_related_resources {:relationship=>"chapters", :source=>"manga"}
#            manga_relationships_manga_characters GET       /api/edge/manga/:manga_id/relationships/manga-characters(.:format)                        manga#show_relationship {:relationship=>"manga_characters"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/manga-characters(.:format)                        manga#create_relationship {:relationship=>"manga_characters"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/manga-characters(.:format)                        manga#update_relationship {:relationship=>"manga_characters"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/manga-characters(.:format)                        manga#destroy_relationship {:relationship=>"manga_characters"}
#                          manga_manga_characters GET       /api/edge/manga/:manga_id/manga-characters(.:format)                                      manga_characters#get_related_resources {:relationship=>"manga_characters", :source=>"manga"}
#                 manga_relationships_manga_staff GET       /api/edge/manga/:manga_id/relationships/manga-staff(.:format)                             manga#show_relationship {:relationship=>"manga_staff"}
#                                                 POST      /api/edge/manga/:manga_id/relationships/manga-staff(.:format)                             manga#create_relationship {:relationship=>"manga_staff"}
#                                                 PUT|PATCH /api/edge/manga/:manga_id/relationships/manga-staff(.:format)                             manga#update_relationship {:relationship=>"manga_staff"}
#                                                 DELETE    /api/edge/manga/:manga_id/relationships/manga-staff(.:format)                             manga#destroy_relationship {:relationship=>"manga_staff"}
#                               manga_manga_staff GET       /api/edge/manga/:manga_id/manga-staff(.:format)                                           manga_staff#get_related_resources {:relationship=>"manga_staff", :source=>"manga"}
#                                     manga_index GET       /api/edge/manga(.:format)                                                                 manga#index
#                                                 POST      /api/edge/manga(.:format)                                                                 manga#create
#                                           manga GET       /api/edge/manga/:id(.:format)                                                             manga#show
#                                                 PATCH     /api/edge/manga/:id(.:format)                                                             manga#update
#                                                 PUT       /api/edge/manga/:id(.:format)                                                             manga#update
#                                                 DELETE    /api/edge/manga/:id(.:format)                                                             manga#destroy
#                      drama_relationships_genres GET       /api/edge/drama/:drama_id/relationships/genres(.:format)                                  dramas#show_relationship {:relationship=>"genres"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/genres(.:format)                                  dramas#create_relationship {:relationship=>"genres"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/genres(.:format)                                  dramas#update_relationship {:relationship=>"genres"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/genres(.:format)                                  dramas#destroy_relationship {:relationship=>"genres"}
#                                    drama_genres GET       /api/edge/drama/:drama_id/genres(.:format)                                                genres#get_related_resources {:relationship=>"genres", :source=>"dramas"}
#                    drama_relationships_castings GET       /api/edge/drama/:drama_id/relationships/castings(.:format)                                dramas#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/castings(.:format)                                dramas#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/castings(.:format)                                dramas#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/castings(.:format)                                dramas#destroy_relationship {:relationship=>"castings"}
#                                  drama_castings GET       /api/edge/drama/:drama_id/castings(.:format)                                              castings#get_related_resources {:relationship=>"castings", :source=>"dramas"}
#                drama_relationships_installments GET       /api/edge/drama/:drama_id/relationships/installments(.:format)                            dramas#show_relationship {:relationship=>"installments"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/installments(.:format)                            dramas#create_relationship {:relationship=>"installments"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/installments(.:format)                            dramas#update_relationship {:relationship=>"installments"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/installments(.:format)                            dramas#destroy_relationship {:relationship=>"installments"}
#                              drama_installments GET       /api/edge/drama/:drama_id/installments(.:format)                                          installments#get_related_resources {:relationship=>"installments", :source=>"dramas"}
#                    drama_relationships_mappings GET       /api/edge/drama/:drama_id/relationships/mappings(.:format)                                dramas#show_relationship {:relationship=>"mappings"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/mappings(.:format)                                dramas#create_relationship {:relationship=>"mappings"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/mappings(.:format)                                dramas#update_relationship {:relationship=>"mappings"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/mappings(.:format)                                dramas#destroy_relationship {:relationship=>"mappings"}
#                                  drama_mappings GET       /api/edge/drama/:drama_id/mappings(.:format)                                              mappings#get_related_resources {:relationship=>"mappings", :source=>"dramas"}
#                     drama_relationships_reviews GET       /api/edge/drama/:drama_id/relationships/reviews(.:format)                                 dramas#show_relationship {:relationship=>"reviews"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/reviews(.:format)                                 dramas#create_relationship {:relationship=>"reviews"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/reviews(.:format)                                 dramas#update_relationship {:relationship=>"reviews"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/reviews(.:format)                                 dramas#destroy_relationship {:relationship=>"reviews"}
#                                   drama_reviews GET       /api/edge/drama/:drama_id/reviews(.:format)                                               reviews#get_related_resources {:relationship=>"reviews", :source=>"dramas"}
#         drama_relationships_media_relationships GET       /api/edge/drama/:drama_id/relationships/media-relationships(.:format)                     dramas#show_relationship {:relationship=>"media_relationships"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/media-relationships(.:format)                     dramas#create_relationship {:relationship=>"media_relationships"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/media-relationships(.:format)                     dramas#update_relationship {:relationship=>"media_relationships"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/media-relationships(.:format)                     dramas#destroy_relationship {:relationship=>"media_relationships"}
#                       drama_media_relationships GET       /api/edge/drama/:drama_id/media-relationships(.:format)                                   media_relationships#get_related_resources {:relationship=>"media_relationships", :source=>"dramas"}
#                    drama_relationships_episodes GET       /api/edge/drama/:drama_id/relationships/episodes(.:format)                                dramas#show_relationship {:relationship=>"episodes"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/episodes(.:format)                                dramas#create_relationship {:relationship=>"episodes"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/episodes(.:format)                                dramas#update_relationship {:relationship=>"episodes"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/episodes(.:format)                                dramas#destroy_relationship {:relationship=>"episodes"}
#                                  drama_episodes GET       /api/edge/drama/:drama_id/episodes(.:format)                                              episodes#get_related_resources {:relationship=>"episodes", :source=>"dramas"}
#            drama_relationships_drama_characters GET       /api/edge/drama/:drama_id/relationships/drama-characters(.:format)                        dramas#show_relationship {:relationship=>"drama_characters"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/drama-characters(.:format)                        dramas#create_relationship {:relationship=>"drama_characters"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/drama-characters(.:format)                        dramas#update_relationship {:relationship=>"drama_characters"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/drama-characters(.:format)                        dramas#destroy_relationship {:relationship=>"drama_characters"}
#                          drama_drama_characters GET       /api/edge/drama/:drama_id/drama-characters(.:format)                                      drama_characters#get_related_resources {:relationship=>"drama_characters", :source=>"dramas"}
#                 drama_relationships_drama_staff GET       /api/edge/drama/:drama_id/relationships/drama-staff(.:format)                             dramas#show_relationship {:relationship=>"drama_staff"}
#                                                 POST      /api/edge/drama/:drama_id/relationships/drama-staff(.:format)                             dramas#create_relationship {:relationship=>"drama_staff"}
#                                                 PUT|PATCH /api/edge/drama/:drama_id/relationships/drama-staff(.:format)                             dramas#update_relationship {:relationship=>"drama_staff"}
#                                                 DELETE    /api/edge/drama/:drama_id/relationships/drama-staff(.:format)                             dramas#destroy_relationship {:relationship=>"drama_staff"}
#                               drama_drama_staff GET       /api/edge/drama/:drama_id/drama-staff(.:format)                                           drama_staff#get_related_resources {:relationship=>"drama_staff", :source=>"dramas"}
#                                     drama_index GET       /api/edge/drama(.:format)                                                                 drama#index
#                                                 POST      /api/edge/drama(.:format)                                                                 drama#create
#                                           drama GET       /api/edge/drama/:id(.:format)                                                             drama#show
#                                                 PATCH     /api/edge/drama/:id(.:format)                                                             drama#update
#                                                 PUT       /api/edge/drama/:id(.:format)                                                             drama#update
#                                                 DELETE    /api/edge/drama/:id(.:format)                                                             drama#destroy
#             anime_character_relationships_anime GET       /api/edge/anime-characters/:anime_character_id/relationships/anime(.:format)              anime_characters#show_relationship {:relationship=>"anime"}
#                                                 PUT|PATCH /api/edge/anime-characters/:anime_character_id/relationships/anime(.:format)              anime_characters#update_relationship {:relationship=>"anime"}
#                                                 DELETE    /api/edge/anime-characters/:anime_character_id/relationships/anime(.:format)              anime_characters#destroy_relationship {:relationship=>"anime"}
#                           anime_character_anime GET       /api/edge/anime-characters/:anime_character_id/anime(.:format)                            anime#get_related_resource {:relationship=>"anime", :source=>"anime_characters"}
#         anime_character_relationships_character GET       /api/edge/anime-characters/:anime_character_id/relationships/character(.:format)          anime_characters#show_relationship {:relationship=>"character"}
#                                                 PUT|PATCH /api/edge/anime-characters/:anime_character_id/relationships/character(.:format)          anime_characters#update_relationship {:relationship=>"character"}
#                                                 DELETE    /api/edge/anime-characters/:anime_character_id/relationships/character(.:format)          anime_characters#destroy_relationship {:relationship=>"character"}
#                       anime_character_character GET       /api/edge/anime-characters/:anime_character_id/character(.:format)                        characters#get_related_resource {:relationship=>"character", :source=>"anime_characters"}
#          anime_character_relationships_castings GET       /api/edge/anime-characters/:anime_character_id/relationships/castings(.:format)           anime_characters#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/anime-characters/:anime_character_id/relationships/castings(.:format)           anime_characters#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/anime-characters/:anime_character_id/relationships/castings(.:format)           anime_characters#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/anime-characters/:anime_character_id/relationships/castings(.:format)           anime_characters#destroy_relationship {:relationship=>"castings"}
#                        anime_character_castings GET       /api/edge/anime-characters/:anime_character_id/castings(.:format)                         anime_castings#get_related_resources {:relationship=>"castings", :source=>"anime_characters"}
#                                anime_characters GET       /api/edge/anime-characters(.:format)                                                      anime_characters#index
#                                                 POST      /api/edge/anime-characters(.:format)                                                      anime_characters#create
#                                 anime_character GET       /api/edge/anime-characters/:id(.:format)                                                  anime_characters#show
#                                                 PATCH     /api/edge/anime-characters/:id(.:format)                                                  anime_characters#update
#                                                 PUT       /api/edge/anime-characters/:id(.:format)                                                  anime_characters#update
#                                                 DELETE    /api/edge/anime-characters/:id(.:format)                                                  anime_characters#destroy
#     anime_casting_relationships_anime_character GET       /api/edge/anime-castings/:anime_casting_id/relationships/anime-character(.:format)        anime_castings#show_relationship {:relationship=>"anime_character"}
#                                                 PUT|PATCH /api/edge/anime-castings/:anime_casting_id/relationships/anime-character(.:format)        anime_castings#update_relationship {:relationship=>"anime_character"}
#                                                 DELETE    /api/edge/anime-castings/:anime_casting_id/relationships/anime-character(.:format)        anime_castings#destroy_relationship {:relationship=>"anime_character"}
#                   anime_casting_anime_character GET       /api/edge/anime-castings/:anime_casting_id/anime-character(.:format)                      anime_characters#get_related_resource {:relationship=>"anime_character", :source=>"anime_castings"}
#              anime_casting_relationships_person GET       /api/edge/anime-castings/:anime_casting_id/relationships/person(.:format)                 anime_castings#show_relationship {:relationship=>"person"}
#                                                 PUT|PATCH /api/edge/anime-castings/:anime_casting_id/relationships/person(.:format)                 anime_castings#update_relationship {:relationship=>"person"}
#                                                 DELETE    /api/edge/anime-castings/:anime_casting_id/relationships/person(.:format)                 anime_castings#destroy_relationship {:relationship=>"person"}
#                            anime_casting_person GET       /api/edge/anime-castings/:anime_casting_id/person(.:format)                               people#get_related_resource {:relationship=>"person", :source=>"anime_castings"}
#            anime_casting_relationships_licensor GET       /api/edge/anime-castings/:anime_casting_id/relationships/licensor(.:format)               anime_castings#show_relationship {:relationship=>"licensor"}
#                                                 PUT|PATCH /api/edge/anime-castings/:anime_casting_id/relationships/licensor(.:format)               anime_castings#update_relationship {:relationship=>"licensor"}
#                                                 DELETE    /api/edge/anime-castings/:anime_casting_id/relationships/licensor(.:format)               anime_castings#destroy_relationship {:relationship=>"licensor"}
#                          anime_casting_licensor GET       /api/edge/anime-castings/:anime_casting_id/licensor(.:format)                             producers#get_related_resource {:relationship=>"licensor", :source=>"anime_castings"}
#                                                 GET       /api/edge/anime-castings(.:format)                                                        anime_castings#index
#                                                 POST      /api/edge/anime-castings(.:format)                                                        anime_castings#create
#                                   anime_casting GET       /api/edge/anime-castings/:id(.:format)                                                    anime_castings#show
#                                                 PATCH     /api/edge/anime-castings/:id(.:format)                                                    anime_castings#update
#                                                 PUT       /api/edge/anime-castings/:id(.:format)                                                    anime_castings#update
#                                                 DELETE    /api/edge/anime-castings/:id(.:format)                                                    anime_castings#destroy
#                 anime_staff_relationships_anime GET       /api/edge/anime-staff/:anime_staff_id/relationships/anime(.:format)                       anime_staff#show_relationship {:relationship=>"anime"}
#                                                 PUT|PATCH /api/edge/anime-staff/:anime_staff_id/relationships/anime(.:format)                       anime_staff#update_relationship {:relationship=>"anime"}
#                                                 DELETE    /api/edge/anime-staff/:anime_staff_id/relationships/anime(.:format)                       anime_staff#destroy_relationship {:relationship=>"anime"}
#                               anime_staff_anime GET       /api/edge/anime-staff/:anime_staff_id/anime(.:format)                                     anime#get_related_resource {:relationship=>"anime", :source=>"anime_staff"}
#                anime_staff_relationships_person GET       /api/edge/anime-staff/:anime_staff_id/relationships/person(.:format)                      anime_staff#show_relationship {:relationship=>"person"}
#                                                 PUT|PATCH /api/edge/anime-staff/:anime_staff_id/relationships/person(.:format)                      anime_staff#update_relationship {:relationship=>"person"}
#                                                 DELETE    /api/edge/anime-staff/:anime_staff_id/relationships/person(.:format)                      anime_staff#destroy_relationship {:relationship=>"person"}
#                              anime_staff_person GET       /api/edge/anime-staff/:anime_staff_id/person(.:format)                                    people#get_related_resource {:relationship=>"person", :source=>"anime_staff"}
#                               anime_staff_index GET       /api/edge/anime-staff(.:format)                                                           anime_staff#index
#                                                 POST      /api/edge/anime-staff(.:format)                                                           anime_staff#create
#                                     anime_staff GET       /api/edge/anime-staff/:id(.:format)                                                       anime_staff#show
#                                                 PATCH     /api/edge/anime-staff/:id(.:format)                                                       anime_staff#update
#                                                 PUT       /api/edge/anime-staff/:id(.:format)                                                       anime_staff#update
#                                                 DELETE    /api/edge/anime-staff/:id(.:format)                                                       anime_staff#destroy
#             drama_character_relationships_drama GET       /api/edge/drama-characters/:drama_character_id/relationships/drama(.:format)              drama_characters#show_relationship {:relationship=>"drama"}
#                                                 PUT|PATCH /api/edge/drama-characters/:drama_character_id/relationships/drama(.:format)              drama_characters#update_relationship {:relationship=>"drama"}
#                                                 DELETE    /api/edge/drama-characters/:drama_character_id/relationships/drama(.:format)              drama_characters#destroy_relationship {:relationship=>"drama"}
#                           drama_character_drama GET       /api/edge/drama-characters/:drama_character_id/drama(.:format)                            dramas#get_related_resource {:relationship=>"drama", :source=>"drama_characters"}
#         drama_character_relationships_character GET       /api/edge/drama-characters/:drama_character_id/relationships/character(.:format)          drama_characters#show_relationship {:relationship=>"character"}
#                                                 PUT|PATCH /api/edge/drama-characters/:drama_character_id/relationships/character(.:format)          drama_characters#update_relationship {:relationship=>"character"}
#                                                 DELETE    /api/edge/drama-characters/:drama_character_id/relationships/character(.:format)          drama_characters#destroy_relationship {:relationship=>"character"}
#                       drama_character_character GET       /api/edge/drama-characters/:drama_character_id/character(.:format)                        characters#get_related_resource {:relationship=>"character", :source=>"drama_characters"}
#          drama_character_relationships_castings GET       /api/edge/drama-characters/:drama_character_id/relationships/castings(.:format)           drama_characters#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/drama-characters/:drama_character_id/relationships/castings(.:format)           drama_characters#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/drama-characters/:drama_character_id/relationships/castings(.:format)           drama_characters#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/drama-characters/:drama_character_id/relationships/castings(.:format)           drama_characters#destroy_relationship {:relationship=>"castings"}
#                        drama_character_castings GET       /api/edge/drama-characters/:drama_character_id/castings(.:format)                         drama_castings#get_related_resources {:relationship=>"castings", :source=>"drama_characters"}
#                                drama_characters GET       /api/edge/drama-characters(.:format)                                                      drama_characters#index
#                                                 POST      /api/edge/drama-characters(.:format)                                                      drama_characters#create
#                                 drama_character GET       /api/edge/drama-characters/:id(.:format)                                                  drama_characters#show
#                                                 PATCH     /api/edge/drama-characters/:id(.:format)                                                  drama_characters#update
#                                                 PUT       /api/edge/drama-characters/:id(.:format)                                                  drama_characters#update
#                                                 DELETE    /api/edge/drama-characters/:id(.:format)                                                  drama_characters#destroy
#     drama_casting_relationships_drama_character GET       /api/edge/drama-castings/:drama_casting_id/relationships/drama-character(.:format)        drama_castings#show_relationship {:relationship=>"drama_character"}
#                                                 PUT|PATCH /api/edge/drama-castings/:drama_casting_id/relationships/drama-character(.:format)        drama_castings#update_relationship {:relationship=>"drama_character"}
#                                                 DELETE    /api/edge/drama-castings/:drama_casting_id/relationships/drama-character(.:format)        drama_castings#destroy_relationship {:relationship=>"drama_character"}
#                   drama_casting_drama_character GET       /api/edge/drama-castings/:drama_casting_id/drama-character(.:format)                      drama_characters#get_related_resource {:relationship=>"drama_character", :source=>"drama_castings"}
#              drama_casting_relationships_person GET       /api/edge/drama-castings/:drama_casting_id/relationships/person(.:format)                 drama_castings#show_relationship {:relationship=>"person"}
#                                                 PUT|PATCH /api/edge/drama-castings/:drama_casting_id/relationships/person(.:format)                 drama_castings#update_relationship {:relationship=>"person"}
#                                                 DELETE    /api/edge/drama-castings/:drama_casting_id/relationships/person(.:format)                 drama_castings#destroy_relationship {:relationship=>"person"}
#                            drama_casting_person GET       /api/edge/drama-castings/:drama_casting_id/person(.:format)                               people#get_related_resource {:relationship=>"person", :source=>"drama_castings"}
#            drama_casting_relationships_licensor GET       /api/edge/drama-castings/:drama_casting_id/relationships/licensor(.:format)               drama_castings#show_relationship {:relationship=>"licensor"}
#                                                 PUT|PATCH /api/edge/drama-castings/:drama_casting_id/relationships/licensor(.:format)               drama_castings#update_relationship {:relationship=>"licensor"}
#                                                 DELETE    /api/edge/drama-castings/:drama_casting_id/relationships/licensor(.:format)               drama_castings#destroy_relationship {:relationship=>"licensor"}
#                          drama_casting_licensor GET       /api/edge/drama-castings/:drama_casting_id/licensor(.:format)                             producers#get_related_resource {:relationship=>"licensor", :source=>"drama_castings"}
#                                                 GET       /api/edge/drama-castings(.:format)                                                        drama_castings#index
#                                                 POST      /api/edge/drama-castings(.:format)                                                        drama_castings#create
#                                   drama_casting GET       /api/edge/drama-castings/:id(.:format)                                                    drama_castings#show
#                                                 PATCH     /api/edge/drama-castings/:id(.:format)                                                    drama_castings#update
#                                                 PUT       /api/edge/drama-castings/:id(.:format)                                                    drama_castings#update
#                                                 DELETE    /api/edge/drama-castings/:id(.:format)                                                    drama_castings#destroy
#                 drama_staff_relationships_drama GET       /api/edge/drama-staff/:drama_staff_id/relationships/drama(.:format)                       drama_staff#show_relationship {:relationship=>"drama"}
#                                                 PUT|PATCH /api/edge/drama-staff/:drama_staff_id/relationships/drama(.:format)                       drama_staff#update_relationship {:relationship=>"drama"}
#                                                 DELETE    /api/edge/drama-staff/:drama_staff_id/relationships/drama(.:format)                       drama_staff#destroy_relationship {:relationship=>"drama"}
#                               drama_staff_drama GET       /api/edge/drama-staff/:drama_staff_id/drama(.:format)                                     dramas#get_related_resource {:relationship=>"drama", :source=>"drama_staff"}
#                drama_staff_relationships_person GET       /api/edge/drama-staff/:drama_staff_id/relationships/person(.:format)                      drama_staff#show_relationship {:relationship=>"person"}
#                                                 PUT|PATCH /api/edge/drama-staff/:drama_staff_id/relationships/person(.:format)                      drama_staff#update_relationship {:relationship=>"person"}
#                                                 DELETE    /api/edge/drama-staff/:drama_staff_id/relationships/person(.:format)                      drama_staff#destroy_relationship {:relationship=>"person"}
#                              drama_staff_person GET       /api/edge/drama-staff/:drama_staff_id/person(.:format)                                    people#get_related_resource {:relationship=>"person", :source=>"drama_staff"}
#                               drama_staff_index GET       /api/edge/drama-staff(.:format)                                                           drama_staff#index
#                                                 POST      /api/edge/drama-staff(.:format)                                                           drama_staff#create
#                                     drama_staff GET       /api/edge/drama-staff/:id(.:format)                                                       drama_staff#show
#                                                 PATCH     /api/edge/drama-staff/:id(.:format)                                                       drama_staff#update
#                                                 PUT       /api/edge/drama-staff/:id(.:format)                                                       drama_staff#update
#                                                 DELETE    /api/edge/drama-staff/:id(.:format)                                                       drama_staff#destroy
#             manga_character_relationships_manga GET       /api/edge/manga-characters/:manga_character_id/relationships/manga(.:format)              manga_characters#show_relationship {:relationship=>"manga"}
#                                                 PUT|PATCH /api/edge/manga-characters/:manga_character_id/relationships/manga(.:format)              manga_characters#update_relationship {:relationship=>"manga"}
#                                                 DELETE    /api/edge/manga-characters/:manga_character_id/relationships/manga(.:format)              manga_characters#destroy_relationship {:relationship=>"manga"}
#                           manga_character_manga GET       /api/edge/manga-characters/:manga_character_id/manga(.:format)                            manga#get_related_resource {:relationship=>"manga", :source=>"manga_characters"}
#         manga_character_relationships_character GET       /api/edge/manga-characters/:manga_character_id/relationships/character(.:format)          manga_characters#show_relationship {:relationship=>"character"}
#                                                 PUT|PATCH /api/edge/manga-characters/:manga_character_id/relationships/character(.:format)          manga_characters#update_relationship {:relationship=>"character"}
#                                                 DELETE    /api/edge/manga-characters/:manga_character_id/relationships/character(.:format)          manga_characters#destroy_relationship {:relationship=>"character"}
#                       manga_character_character GET       /api/edge/manga-characters/:manga_character_id/character(.:format)                        characters#get_related_resource {:relationship=>"character", :source=>"manga_characters"}
#                                manga_characters GET       /api/edge/manga-characters(.:format)                                                      manga_characters#index
#                                                 POST      /api/edge/manga-characters(.:format)                                                      manga_characters#create
#                                 manga_character GET       /api/edge/manga-characters/:id(.:format)                                                  manga_characters#show
#                                                 PATCH     /api/edge/manga-characters/:id(.:format)                                                  manga_characters#update
#                                                 PUT       /api/edge/manga-characters/:id(.:format)                                                  manga_characters#update
#                                                 DELETE    /api/edge/manga-characters/:id(.:format)                                                  manga_characters#destroy
#                 manga_staff_relationships_manga GET       /api/edge/manga-staff/:manga_staff_id/relationships/manga(.:format)                       manga_staff#show_relationship {:relationship=>"manga"}
#                                                 PUT|PATCH /api/edge/manga-staff/:manga_staff_id/relationships/manga(.:format)                       manga_staff#update_relationship {:relationship=>"manga"}
#                                                 DELETE    /api/edge/manga-staff/:manga_staff_id/relationships/manga(.:format)                       manga_staff#destroy_relationship {:relationship=>"manga"}
#                               manga_staff_manga GET       /api/edge/manga-staff/:manga_staff_id/manga(.:format)                                     manga#get_related_resource {:relationship=>"manga", :source=>"manga_staff"}
#                manga_staff_relationships_person GET       /api/edge/manga-staff/:manga_staff_id/relationships/person(.:format)                      manga_staff#show_relationship {:relationship=>"person"}
#                                                 PUT|PATCH /api/edge/manga-staff/:manga_staff_id/relationships/person(.:format)                      manga_staff#update_relationship {:relationship=>"person"}
#                                                 DELETE    /api/edge/manga-staff/:manga_staff_id/relationships/person(.:format)                      manga_staff#destroy_relationship {:relationship=>"person"}
#                              manga_staff_person GET       /api/edge/manga-staff/:manga_staff_id/person(.:format)                                    people#get_related_resource {:relationship=>"person", :source=>"manga_staff"}
#                               manga_staff_index GET       /api/edge/manga-staff(.:format)                                                           manga_staff#index
#                                                 POST      /api/edge/manga-staff(.:format)                                                           manga_staff#create
#                                     manga_staff GET       /api/edge/manga-staff/:id(.:format)                                                       manga_staff#show
#                                                 PATCH     /api/edge/manga-staff/:id(.:format)                                                       manga_staff#update
#                                                 PUT       /api/edge/manga-staff/:id(.:format)                                                       manga_staff#update
#                                                 DELETE    /api/edge/manga-staff/:id(.:format)                                                       manga_staff#destroy
#                     mapping_relationships_media GET       /api/edge/mappings/:mapping_id/relationships/media(.:format)                              mappings#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/mappings/:mapping_id/relationships/media(.:format)                              mappings#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/mappings/:mapping_id/relationships/media(.:format)                              mappings#destroy_relationship {:relationship=>"media"}
#                                   mapping_media GET       /api/edge/mappings/:mapping_id/media(.:format)                                            media#get_related_resource {:relationship=>"media", :source=>"mappings"}
#                                        mappings GET       /api/edge/mappings(.:format)                                                              mappings#index
#                                                 POST      /api/edge/mappings(.:format)                                                              mappings#create
#                                         mapping GET       /api/edge/mappings/:id(.:format)                                                          mappings#show
#                                                 PATCH     /api/edge/mappings/:id(.:format)                                                          mappings#update
#                                                 PUT       /api/edge/mappings/:id(.:format)                                                          mappings#update
#                                                 DELETE    /api/edge/mappings/:id(.:format)                                                          mappings#destroy
#                                          genres GET       /api/edge/genres(.:format)                                                                genres#index
#                                                 POST      /api/edge/genres(.:format)                                                                genres#create
#                                           genre GET       /api/edge/genres/:id(.:format)                                                            genres#show
#                                                 PATCH     /api/edge/genres/:id(.:format)                                                            genres#update
#                                                 PUT       /api/edge/genres/:id(.:format)                                                            genres#update
#                                                 DELETE    /api/edge/genres/:id(.:format)                                                            genres#destroy
#           streaming_link_relationships_streamer GET       /api/edge/streaming-links/:streaming_link_id/relationships/streamer(.:format)             streaming_links#show_relationship {:relationship=>"streamer"}
#                                                 PUT|PATCH /api/edge/streaming-links/:streaming_link_id/relationships/streamer(.:format)             streaming_links#update_relationship {:relationship=>"streamer"}
#                                                 DELETE    /api/edge/streaming-links/:streaming_link_id/relationships/streamer(.:format)             streaming_links#destroy_relationship {:relationship=>"streamer"}
#                         streaming_link_streamer GET       /api/edge/streaming-links/:streaming_link_id/streamer(.:format)                           streamers#get_related_resource {:relationship=>"streamer", :source=>"streaming_links"}
#              streaming_link_relationships_media GET       /api/edge/streaming-links/:streaming_link_id/relationships/media(.:format)                streaming_links#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/streaming-links/:streaming_link_id/relationships/media(.:format)                streaming_links#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/streaming-links/:streaming_link_id/relationships/media(.:format)                streaming_links#destroy_relationship {:relationship=>"media"}
#                            streaming_link_media GET       /api/edge/streaming-links/:streaming_link_id/media(.:format)                              media#get_related_resource {:relationship=>"media", :source=>"streaming_links"}
#                                 streaming_links GET       /api/edge/streaming-links(.:format)                                                       streaming_links#index
#                                                 POST      /api/edge/streaming-links(.:format)                                                       streaming_links#create
#                                  streaming_link GET       /api/edge/streaming-links/:id(.:format)                                                   streaming_links#show
#                                                 PATCH     /api/edge/streaming-links/:id(.:format)                                                   streaming_links#update
#                                                 PUT       /api/edge/streaming-links/:id(.:format)                                                   streaming_links#update
#                                                 DELETE    /api/edge/streaming-links/:id(.:format)                                                   streaming_links#destroy
#          streamer_relationships_streaming_links GET       /api/edge/streamers/:streamer_id/relationships/streaming-links(.:format)                  streamers#show_relationship {:relationship=>"streaming_links"}
#                                                 POST      /api/edge/streamers/:streamer_id/relationships/streaming-links(.:format)                  streamers#create_relationship {:relationship=>"streaming_links"}
#                                                 PUT|PATCH /api/edge/streamers/:streamer_id/relationships/streaming-links(.:format)                  streamers#update_relationship {:relationship=>"streaming_links"}
#                                                 DELETE    /api/edge/streamers/:streamer_id/relationships/streaming-links(.:format)                  streamers#destroy_relationship {:relationship=>"streaming_links"}
#                        streamer_streaming_links GET       /api/edge/streamers/:streamer_id/streaming-links(.:format)                                streaming_links#get_related_resources {:relationship=>"streaming_links", :source=>"streamers"}
#                                       streamers GET       /api/edge/streamers(.:format)                                                             streamers#index
#                                                 POST      /api/edge/streamers(.:format)                                                             streamers#create
#                                        streamer GET       /api/edge/streamers/:id(.:format)                                                         streamers#show
#                                                 PATCH     /api/edge/streamers/:id(.:format)                                                         streamers#update
#                                                 PUT       /api/edge/streamers/:id(.:format)                                                         streamers#update
#                                                 DELETE    /api/edge/streamers/:id(.:format)                                                         streamers#destroy
#         media_relationship_relationships_source GET       /api/edge/media-relationships/:media_relationship_id/relationships/source(.:format)       media_relationships#show_relationship {:relationship=>"source"}
#                                                 PUT|PATCH /api/edge/media-relationships/:media_relationship_id/relationships/source(.:format)       media_relationships#update_relationship {:relationship=>"source"}
#                                                 DELETE    /api/edge/media-relationships/:media_relationship_id/relationships/source(.:format)       media_relationships#destroy_relationship {:relationship=>"source"}
#                       media_relationship_source GET       /api/edge/media-relationships/:media_relationship_id/source(.:format)                     sources#get_related_resource {:relationship=>"source", :source=>"media_relationships"}
#    media_relationship_relationships_destination GET       /api/edge/media-relationships/:media_relationship_id/relationships/destination(.:format)  media_relationships#show_relationship {:relationship=>"destination"}
#                                                 PUT|PATCH /api/edge/media-relationships/:media_relationship_id/relationships/destination(.:format)  media_relationships#update_relationship {:relationship=>"destination"}
#                                                 DELETE    /api/edge/media-relationships/:media_relationship_id/relationships/destination(.:format)  media_relationships#destroy_relationship {:relationship=>"destination"}
#                  media_relationship_destination GET       /api/edge/media-relationships/:media_relationship_id/destination(.:format)                destinations#get_related_resource {:relationship=>"destination", :source=>"media_relationships"}
#                             media_relationships GET       /api/edge/media-relationships(.:format)                                                   media_relationships#index
#                                                 POST      /api/edge/media-relationships(.:format)                                                   media_relationships#create
#                              media_relationship GET       /api/edge/media-relationships/:id(.:format)                                               media_relationships#show
#                                                 PATCH     /api/edge/media-relationships/:id(.:format)                                               media_relationships#update
#                                                 PUT       /api/edge/media-relationships/:id(.:format)                                               media_relationships#update
#                                                 DELETE    /api/edge/media-relationships/:id(.:format)                                               media_relationships#destroy
#            anime_production_relationships_anime GET       /api/edge/anime-productions/:anime_production_id/relationships/anime(.:format)            anime_productions#show_relationship {:relationship=>"anime"}
#                                                 PUT|PATCH /api/edge/anime-productions/:anime_production_id/relationships/anime(.:format)            anime_productions#update_relationship {:relationship=>"anime"}
#                                                 DELETE    /api/edge/anime-productions/:anime_production_id/relationships/anime(.:format)            anime_productions#destroy_relationship {:relationship=>"anime"}
#                          anime_production_anime GET       /api/edge/anime-productions/:anime_production_id/anime(.:format)                          anime#get_related_resource {:relationship=>"anime", :source=>"anime_productions"}
#         anime_production_relationships_producer GET       /api/edge/anime-productions/:anime_production_id/relationships/producer(.:format)         anime_productions#show_relationship {:relationship=>"producer"}
#                                                 PUT|PATCH /api/edge/anime-productions/:anime_production_id/relationships/producer(.:format)         anime_productions#update_relationship {:relationship=>"producer"}
#                                                 DELETE    /api/edge/anime-productions/:anime_production_id/relationships/producer(.:format)         anime_productions#destroy_relationship {:relationship=>"producer"}
#                       anime_production_producer GET       /api/edge/anime-productions/:anime_production_id/producer(.:format)                       producers#get_related_resource {:relationship=>"producer", :source=>"anime_productions"}
#                               anime_productions GET       /api/edge/anime-productions(.:format)                                                     anime_productions#index
#                                                 POST      /api/edge/anime-productions(.:format)                                                     anime_productions#create
#                                anime_production GET       /api/edge/anime-productions/:id(.:format)                                                 anime_productions#show
#                                                 PATCH     /api/edge/anime-productions/:id(.:format)                                                 anime_productions#update
#                                                 PUT       /api/edge/anime-productions/:id(.:format)                                                 anime_productions#update
#                                                 DELETE    /api/edge/anime-productions/:id(.:format)                                                 anime_productions#destroy
#                     episode_relationships_media GET       /api/edge/episodes/:episode_id/relationships/media(.:format)                              episodes#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/episodes/:episode_id/relationships/media(.:format)                              episodes#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/episodes/:episode_id/relationships/media(.:format)                              episodes#destroy_relationship {:relationship=>"media"}
#                                   episode_media GET       /api/edge/episodes/:episode_id/media(.:format)                                            media#get_related_resource {:relationship=>"media", :source=>"episodes"}
#                                        episodes GET       /api/edge/episodes(.:format)                                                              episodes#index
#                                                 POST      /api/edge/episodes(.:format)                                                              episodes#create
#                                         episode GET       /api/edge/episodes/:id(.:format)                                                          episodes#show
#                                                 PATCH     /api/edge/episodes/:id(.:format)                                                          episodes#update
#                                                 PUT       /api/edge/episodes/:id(.:format)                                                          episodes#update
#                                                 DELETE    /api/edge/episodes/:id(.:format)                                                          episodes#destroy
#                         stat_relationships_user GET       /api/edge/stats/:stat_id/relationships/user(.:format)                                     stats#show_relationship {:relationship=>"user"}
#                                       stat_user GET       /api/edge/stats/:stat_id/user(.:format)                                                   users#get_related_resource {:relationship=>"user", :source=>"stats"}
#                                           stats GET       /api/edge/stats(.:format)                                                                 stats#index
#                                            stat GET       /api/edge/stats/:id(.:format)                                                             stats#show
#                     casting_relationships_media GET       /api/edge/castings/:casting_id/relationships/media(.:format)                              castings#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/castings/:casting_id/relationships/media(.:format)                              castings#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/castings/:casting_id/relationships/media(.:format)                              castings#destroy_relationship {:relationship=>"media"}
#                                   casting_media GET       /api/edge/castings/:casting_id/media(.:format)                                            media#get_related_resource {:relationship=>"media", :source=>"castings"}
#                 casting_relationships_character GET       /api/edge/castings/:casting_id/relationships/character(.:format)                          castings#show_relationship {:relationship=>"character"}
#                                                 PUT|PATCH /api/edge/castings/:casting_id/relationships/character(.:format)                          castings#update_relationship {:relationship=>"character"}
#                                                 DELETE    /api/edge/castings/:casting_id/relationships/character(.:format)                          castings#destroy_relationship {:relationship=>"character"}
#                               casting_character GET       /api/edge/castings/:casting_id/character(.:format)                                        characters#get_related_resource {:relationship=>"character", :source=>"castings"}
#                    casting_relationships_person GET       /api/edge/castings/:casting_id/relationships/person(.:format)                             castings#show_relationship {:relationship=>"person"}
#                                                 PUT|PATCH /api/edge/castings/:casting_id/relationships/person(.:format)                             castings#update_relationship {:relationship=>"person"}
#                                                 DELETE    /api/edge/castings/:casting_id/relationships/person(.:format)                             castings#destroy_relationship {:relationship=>"person"}
#                                  casting_person GET       /api/edge/castings/:casting_id/person(.:format)                                           people#get_related_resource {:relationship=>"person", :source=>"castings"}
#                                        castings GET       /api/edge/castings(.:format)                                                              castings#index
#                                                 POST      /api/edge/castings(.:format)                                                              castings#create
#                                         casting GET       /api/edge/castings/:id(.:format)                                                          castings#show
#                                                 PATCH     /api/edge/castings/:id(.:format)                                                          castings#update
#                                                 PUT       /api/edge/castings/:id(.:format)                                                          castings#update
#                                                 DELETE    /api/edge/castings/:id(.:format)                                                          castings#destroy
#                                                 GET       /api/edge/anime/:anime_id/_languages(.:format)                                            anime#languages
#            franchise_relationships_installments GET       /api/edge/franchises/:franchise_id/relationships/installments(.:format)                   franchises#show_relationship {:relationship=>"installments"}
#                                                 POST      /api/edge/franchises/:franchise_id/relationships/installments(.:format)                   franchises#create_relationship {:relationship=>"installments"}
#                                                 PUT|PATCH /api/edge/franchises/:franchise_id/relationships/installments(.:format)                   franchises#update_relationship {:relationship=>"installments"}
#                                                 DELETE    /api/edge/franchises/:franchise_id/relationships/installments(.:format)                   franchises#destroy_relationship {:relationship=>"installments"}
#                          franchise_installments GET       /api/edge/franchises/:franchise_id/installments(.:format)                                 installments#get_related_resources {:relationship=>"installments", :source=>"franchises"}
#                                      franchises GET       /api/edge/franchises(.:format)                                                            franchises#index
#                                                 POST      /api/edge/franchises(.:format)                                                            franchises#create
#                                       franchise GET       /api/edge/franchises/:id(.:format)                                                        franchises#show
#                                                 PATCH     /api/edge/franchises/:id(.:format)                                                        franchises#update
#                                                 PUT       /api/edge/franchises/:id(.:format)                                                        franchises#update
#                                                 DELETE    /api/edge/franchises/:id(.:format)                                                        franchises#destroy
#             installment_relationships_franchise GET       /api/edge/installments/:installment_id/relationships/franchise(.:format)                  installments#show_relationship {:relationship=>"franchise"}
#                                                 PUT|PATCH /api/edge/installments/:installment_id/relationships/franchise(.:format)                  installments#update_relationship {:relationship=>"franchise"}
#                                                 DELETE    /api/edge/installments/:installment_id/relationships/franchise(.:format)                  installments#destroy_relationship {:relationship=>"franchise"}
#                           installment_franchise GET       /api/edge/installments/:installment_id/franchise(.:format)                                franchises#get_related_resource {:relationship=>"franchise", :source=>"installments"}
#                 installment_relationships_media GET       /api/edge/installments/:installment_id/relationships/media(.:format)                      installments#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/installments/:installment_id/relationships/media(.:format)                      installments#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/installments/:installment_id/relationships/media(.:format)                      installments#destroy_relationship {:relationship=>"media"}
#                               installment_media GET       /api/edge/installments/:installment_id/media(.:format)                                    media#get_related_resource {:relationship=>"media", :source=>"installments"}
#                                    installments GET       /api/edge/installments(.:format)                                                          installments#index
#                                                 POST      /api/edge/installments(.:format)                                                          installments#create
#                                     installment GET       /api/edge/installments/:id(.:format)                                                      installments#show
#                                                 PATCH     /api/edge/installments/:id(.:format)                                                      installments#update
#                                                 PUT       /api/edge/installments/:id(.:format)                                                      installments#update
#                                                 DELETE    /api/edge/installments/:id(.:format)                                                      installments#destroy
#              review_relationships_library_entry GET       /api/edge/reviews/:review_id/relationships/library-entry(.:format)                        reviews#show_relationship {:relationship=>"library_entry"}
#                                                 PUT|PATCH /api/edge/reviews/:review_id/relationships/library-entry(.:format)                        reviews#update_relationship {:relationship=>"library_entry"}
#                                                 DELETE    /api/edge/reviews/:review_id/relationships/library-entry(.:format)                        reviews#destroy_relationship {:relationship=>"library_entry"}
#                            review_library_entry GET       /api/edge/reviews/:review_id/library-entry(.:format)                                      library_entries#get_related_resource {:relationship=>"library_entry", :source=>"reviews"}
#                      review_relationships_media GET       /api/edge/reviews/:review_id/relationships/media(.:format)                                reviews#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/reviews/:review_id/relationships/media(.:format)                                reviews#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/reviews/:review_id/relationships/media(.:format)                                reviews#destroy_relationship {:relationship=>"media"}
#                                    review_media GET       /api/edge/reviews/:review_id/media(.:format)                                              media#get_related_resource {:relationship=>"media", :source=>"reviews"}
#                       review_relationships_user GET       /api/edge/reviews/:review_id/relationships/user(.:format)                                 reviews#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/reviews/:review_id/relationships/user(.:format)                                 reviews#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/reviews/:review_id/relationships/user(.:format)                                 reviews#destroy_relationship {:relationship=>"user"}
#                                     review_user GET       /api/edge/reviews/:review_id/user(.:format)                                               users#get_related_resource {:relationship=>"user", :source=>"reviews"}
#                                         reviews GET       /api/edge/reviews(.:format)                                                               reviews#index
#                                                 POST      /api/edge/reviews(.:format)                                                               reviews#create
#                                          review GET       /api/edge/reviews/:id(.:format)                                                           reviews#show
#                                                 PATCH     /api/edge/reviews/:id(.:format)                                                           reviews#update
#                                                 PUT       /api/edge/reviews/:id(.:format)                                                           reviews#update
#                                                 DELETE    /api/edge/reviews/:id(.:format)                                                           reviews#destroy
#                review_like_relationships_review GET       /api/edge/review-likes/:review_like_id/relationships/review(.:format)                     review_likes#show_relationship {:relationship=>"review"}
#                                                 PUT|PATCH /api/edge/review-likes/:review_like_id/relationships/review(.:format)                     review_likes#update_relationship {:relationship=>"review"}
#                                                 DELETE    /api/edge/review-likes/:review_like_id/relationships/review(.:format)                     review_likes#destroy_relationship {:relationship=>"review"}
#                              review_like_review GET       /api/edge/review-likes/:review_like_id/review(.:format)                                   reviews#get_related_resource {:relationship=>"review", :source=>"review_likes"}
#                  review_like_relationships_user GET       /api/edge/review-likes/:review_like_id/relationships/user(.:format)                       review_likes#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/review-likes/:review_like_id/relationships/user(.:format)                       review_likes#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/review-likes/:review_like_id/relationships/user(.:format)                       review_likes#destroy_relationship {:relationship=>"user"}
#                                review_like_user GET       /api/edge/review-likes/:review_like_id/user(.:format)                                     users#get_related_resource {:relationship=>"user", :source=>"review_likes"}
#                                    review_likes GET       /api/edge/review-likes(.:format)                                                          review_likes#index
#                                                 POST      /api/edge/review-likes(.:format)                                                          review_likes#create
#                                     review_like GET       /api/edge/review-likes/:id(.:format)                                                      review_likes#show
#                                                 PATCH     /api/edge/review-likes/:id(.:format)                                                      review_likes#update
#                                                 PUT       /api/edge/review-likes/:id(.:format)                                                      review_likes#update
#                                                 DELETE    /api/edge/review-likes/:id(.:format)                                                      review_likes#destroy
#                                                 GET       /api/edge/trending/:namespace(.:format)                                                   trending#index
#           character_relationships_primary_media GET       /api/edge/characters/:character_id/relationships/primary-media(.:format)                  characters#show_relationship {:relationship=>"primary_media"}
#                                                 PUT|PATCH /api/edge/characters/:character_id/relationships/primary-media(.:format)                  characters#update_relationship {:relationship=>"primary_media"}
#                                                 DELETE    /api/edge/characters/:character_id/relationships/primary-media(.:format)                  characters#destroy_relationship {:relationship=>"primary_media"}
#                         character_primary_media GET       /api/edge/characters/:character_id/primary-media(.:format)                                primary_media#get_related_resource {:relationship=>"primary_media", :source=>"characters"}
#                character_relationships_castings GET       /api/edge/characters/:character_id/relationships/castings(.:format)                       characters#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/characters/:character_id/relationships/castings(.:format)                       characters#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/characters/:character_id/relationships/castings(.:format)                       characters#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/characters/:character_id/relationships/castings(.:format)                       characters#destroy_relationship {:relationship=>"castings"}
#                              character_castings GET       /api/edge/characters/:character_id/castings(.:format)                                     castings#get_related_resources {:relationship=>"castings", :source=>"characters"}
#                                      characters GET       /api/edge/characters(.:format)                                                            characters#index
#                                                 POST      /api/edge/characters(.:format)                                                            characters#create
#                                       character GET       /api/edge/characters/:id(.:format)                                                        characters#show
#                                                 PATCH     /api/edge/characters/:id(.:format)                                                        characters#update
#                                                 PUT       /api/edge/characters/:id(.:format)                                                        characters#update
#                                                 DELETE    /api/edge/characters/:id(.:format)                                                        characters#destroy
#                   person_relationships_castings GET       /api/edge/people/:person_id/relationships/castings(.:format)                              people#show_relationship {:relationship=>"castings"}
#                                                 POST      /api/edge/people/:person_id/relationships/castings(.:format)                              people#create_relationship {:relationship=>"castings"}
#                                                 PUT|PATCH /api/edge/people/:person_id/relationships/castings(.:format)                              people#update_relationship {:relationship=>"castings"}
#                                                 DELETE    /api/edge/people/:person_id/relationships/castings(.:format)                              people#destroy_relationship {:relationship=>"castings"}
#                                 person_castings GET       /api/edge/people/:person_id/castings(.:format)                                            castings#get_related_resources {:relationship=>"castings", :source=>"people"}
#                                          people GET       /api/edge/people(.:format)                                                                people#index
#                                                 POST      /api/edge/people(.:format)                                                                people#create
#                                          person GET       /api/edge/people/:id(.:format)                                                            people#show
#                                                 PATCH     /api/edge/people/:id(.:format)                                                            people#update
#                                                 PUT       /api/edge/people/:id(.:format)                                                            people#update
#                                                 DELETE    /api/edge/people/:id(.:format)                                                            people#destroy
#        producer_relationships_anime_productions GET       /api/edge/producers/:producer_id/relationships/anime-productions(.:format)                producers#show_relationship {:relationship=>"anime_productions"}
#                                                 POST      /api/edge/producers/:producer_id/relationships/anime-productions(.:format)                producers#create_relationship {:relationship=>"anime_productions"}
#                                                 PUT|PATCH /api/edge/producers/:producer_id/relationships/anime-productions(.:format)                producers#update_relationship {:relationship=>"anime_productions"}
#                                                 DELETE    /api/edge/producers/:producer_id/relationships/anime-productions(.:format)                producers#destroy_relationship {:relationship=>"anime_productions"}
#                      producer_anime_productions GET       /api/edge/producers/:producer_id/anime-productions(.:format)                              anime_productions#get_related_resources {:relationship=>"anime_productions", :source=>"producers"}
#                                       producers GET       /api/edge/producers(.:format)                                                             producers#index
#                                                 POST      /api/edge/producers(.:format)                                                             producers#create
#                                        producer GET       /api/edge/producers/:id(.:format)                                                         producers#show
#                                                 PATCH     /api/edge/producers/:id(.:format)                                                         producers#update
#                                                 PUT       /api/edge/producers/:id(.:format)                                                         producers#update
#                                                 DELETE    /api/edge/producers/:id(.:format)                                                         producers#destroy
#                         post_relationships_user GET       /api/edge/posts/:post_id/relationships/user(.:format)                                     posts#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/user(.:format)                                     posts#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/user(.:format)                                     posts#destroy_relationship {:relationship=>"user"}
#                                       post_user GET       /api/edge/posts/:post_id/user(.:format)                                                   users#get_related_resource {:relationship=>"user", :source=>"posts"}
#                  post_relationships_target_user GET       /api/edge/posts/:post_id/relationships/target-user(.:format)                              posts#show_relationship {:relationship=>"target_user"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/target-user(.:format)                              posts#update_relationship {:relationship=>"target_user"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/target-user(.:format)                              posts#destroy_relationship {:relationship=>"target_user"}
#                                post_target_user GET       /api/edge/posts/:post_id/target-user(.:format)                                            users#get_related_resource {:relationship=>"target_user", :source=>"posts"}
#                 post_relationships_target_group GET       /api/edge/posts/:post_id/relationships/target-group(.:format)                             posts#show_relationship {:relationship=>"target_group"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/target-group(.:format)                             posts#update_relationship {:relationship=>"target_group"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/target-group(.:format)                             posts#destroy_relationship {:relationship=>"target_group"}
#                               post_target_group GET       /api/edge/posts/:post_id/target-group(.:format)                                           groups#get_related_resource {:relationship=>"target_group", :source=>"posts"}
#                        post_relationships_media GET       /api/edge/posts/:post_id/relationships/media(.:format)                                    posts#show_relationship {:relationship=>"media"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/media(.:format)                                    posts#update_relationship {:relationship=>"media"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/media(.:format)                                    posts#destroy_relationship {:relationship=>"media"}
#                                      post_media GET       /api/edge/posts/:post_id/media(.:format)                                                  media#get_related_resource {:relationship=>"media", :source=>"posts"}
#                 post_relationships_spoiled_unit GET       /api/edge/posts/:post_id/relationships/spoiled-unit(.:format)                             posts#show_relationship {:relationship=>"spoiled_unit"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/spoiled-unit(.:format)                             posts#update_relationship {:relationship=>"spoiled_unit"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/spoiled-unit(.:format)                             posts#destroy_relationship {:relationship=>"spoiled_unit"}
#                               post_spoiled_unit GET       /api/edge/posts/:post_id/spoiled-unit(.:format)                                           spoiled_units#get_related_resource {:relationship=>"spoiled_unit", :source=>"posts"}
#                   post_relationships_post_likes GET       /api/edge/posts/:post_id/relationships/post-likes(.:format)                               posts#show_relationship {:relationship=>"post_likes"}
#                                                 POST      /api/edge/posts/:post_id/relationships/post-likes(.:format)                               posts#create_relationship {:relationship=>"post_likes"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/post-likes(.:format)                               posts#update_relationship {:relationship=>"post_likes"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/post-likes(.:format)                               posts#destroy_relationship {:relationship=>"post_likes"}
#                                 post_post_likes GET       /api/edge/posts/:post_id/post-likes(.:format)                                             post_likes#get_related_resources {:relationship=>"post_likes", :source=>"posts"}
#                     post_relationships_comments GET       /api/edge/posts/:post_id/relationships/comments(.:format)                                 posts#show_relationship {:relationship=>"comments"}
#                                                 POST      /api/edge/posts/:post_id/relationships/comments(.:format)                                 posts#create_relationship {:relationship=>"comments"}
#                                                 PUT|PATCH /api/edge/posts/:post_id/relationships/comments(.:format)                                 posts#update_relationship {:relationship=>"comments"}
#                                                 DELETE    /api/edge/posts/:post_id/relationships/comments(.:format)                                 posts#destroy_relationship {:relationship=>"comments"}
#                                   post_comments GET       /api/edge/posts/:post_id/comments(.:format)                                               comments#get_related_resources {:relationship=>"comments", :source=>"posts"}
#                                           posts GET       /api/edge/posts(.:format)                                                                 posts#index
#                                                 POST      /api/edge/posts(.:format)                                                                 posts#create
#                                            post GET       /api/edge/posts/:id(.:format)                                                             posts#show
#                                                 PATCH     /api/edge/posts/:id(.:format)                                                             posts#update
#                                                 PUT       /api/edge/posts/:id(.:format)                                                             posts#update
#                                                 DELETE    /api/edge/posts/:id(.:format)                                                             posts#destroy
#                    post_like_relationships_post GET       /api/edge/post-likes/:post_like_id/relationships/post(.:format)                           post_likes#show_relationship {:relationship=>"post"}
#                                                 PUT|PATCH /api/edge/post-likes/:post_like_id/relationships/post(.:format)                           post_likes#update_relationship {:relationship=>"post"}
#                                                 DELETE    /api/edge/post-likes/:post_like_id/relationships/post(.:format)                           post_likes#destroy_relationship {:relationship=>"post"}
#                                  post_like_post GET       /api/edge/post-likes/:post_like_id/post(.:format)                                         posts#get_related_resource {:relationship=>"post", :source=>"post_likes"}
#                    post_like_relationships_user GET       /api/edge/post-likes/:post_like_id/relationships/user(.:format)                           post_likes#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/post-likes/:post_like_id/relationships/user(.:format)                           post_likes#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/post-likes/:post_like_id/relationships/user(.:format)                           post_likes#destroy_relationship {:relationship=>"user"}
#                                  post_like_user GET       /api/edge/post-likes/:post_like_id/user(.:format)                                         users#get_related_resource {:relationship=>"user", :source=>"post_likes"}
#                                      post_likes GET       /api/edge/post-likes(.:format)                                                            post_likes#index
#                                                 POST      /api/edge/post-likes(.:format)                                                            post_likes#create
#                                       post_like GET       /api/edge/post-likes/:id(.:format)                                                        post_likes#show
#                                                 PATCH     /api/edge/post-likes/:id(.:format)                                                        post_likes#update
#                                                 PUT       /api/edge/post-likes/:id(.:format)                                                        post_likes#update
#                                                 DELETE    /api/edge/post-likes/:id(.:format)                                                        post_likes#destroy
#                      comment_relationships_user GET       /api/edge/comments/:comment_id/relationships/user(.:format)                               comments#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/comments/:comment_id/relationships/user(.:format)                               comments#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/comments/:comment_id/relationships/user(.:format)                               comments#destroy_relationship {:relationship=>"user"}
#                                    comment_user GET       /api/edge/comments/:comment_id/user(.:format)                                             users#get_related_resource {:relationship=>"user", :source=>"comments"}
#                      comment_relationships_post GET       /api/edge/comments/:comment_id/relationships/post(.:format)                               comments#show_relationship {:relationship=>"post"}
#                                                 PUT|PATCH /api/edge/comments/:comment_id/relationships/post(.:format)                               comments#update_relationship {:relationship=>"post"}
#                                                 DELETE    /api/edge/comments/:comment_id/relationships/post(.:format)                               comments#destroy_relationship {:relationship=>"post"}
#                                    comment_post GET       /api/edge/comments/:comment_id/post(.:format)                                             posts#get_related_resource {:relationship=>"post", :source=>"comments"}
#                    comment_relationships_parent GET       /api/edge/comments/:comment_id/relationships/parent(.:format)                             comments#show_relationship {:relationship=>"parent"}
#                                                 PUT|PATCH /api/edge/comments/:comment_id/relationships/parent(.:format)                             comments#update_relationship {:relationship=>"parent"}
#                                                 DELETE    /api/edge/comments/:comment_id/relationships/parent(.:format)                             comments#destroy_relationship {:relationship=>"parent"}
#                                  comment_parent GET       /api/edge/comments/:comment_id/parent(.:format)                                           comments#get_related_resource {:relationship=>"parent", :source=>"comments"}
#                     comment_relationships_likes GET       /api/edge/comments/:comment_id/relationships/likes(.:format)                              comments#show_relationship {:relationship=>"likes"}
#                                                 POST      /api/edge/comments/:comment_id/relationships/likes(.:format)                              comments#create_relationship {:relationship=>"likes"}
#                                                 PUT|PATCH /api/edge/comments/:comment_id/relationships/likes(.:format)                              comments#update_relationship {:relationship=>"likes"}
#                                                 DELETE    /api/edge/comments/:comment_id/relationships/likes(.:format)                              comments#destroy_relationship {:relationship=>"likes"}
#                                   comment_likes GET       /api/edge/comments/:comment_id/likes(.:format)                                            comment_likes#get_related_resources {:relationship=>"likes", :source=>"comments"}
#                   comment_relationships_replies GET       /api/edge/comments/:comment_id/relationships/replies(.:format)                            comments#show_relationship {:relationship=>"replies"}
#                                                 POST      /api/edge/comments/:comment_id/relationships/replies(.:format)                            comments#create_relationship {:relationship=>"replies"}
#                                                 PUT|PATCH /api/edge/comments/:comment_id/relationships/replies(.:format)                            comments#update_relationship {:relationship=>"replies"}
#                                                 DELETE    /api/edge/comments/:comment_id/relationships/replies(.:format)                            comments#destroy_relationship {:relationship=>"replies"}
#                                 comment_replies GET       /api/edge/comments/:comment_id/replies(.:format)                                          comments#get_related_resources {:relationship=>"replies", :source=>"comments"}
#                                        comments GET       /api/edge/comments(.:format)                                                              comments#index
#                                                 POST      /api/edge/comments(.:format)                                                              comments#create
#                                         comment GET       /api/edge/comments/:id(.:format)                                                          comments#show
#                                                 PATCH     /api/edge/comments/:id(.:format)                                                          comments#update
#                                                 PUT       /api/edge/comments/:id(.:format)                                                          comments#update
#                                                 DELETE    /api/edge/comments/:id(.:format)                                                          comments#destroy
#              comment_like_relationships_comment GET       /api/edge/comment-likes/:comment_like_id/relationships/comment(.:format)                  comment_likes#show_relationship {:relationship=>"comment"}
#                                                 PUT|PATCH /api/edge/comment-likes/:comment_like_id/relationships/comment(.:format)                  comment_likes#update_relationship {:relationship=>"comment"}
#                                                 DELETE    /api/edge/comment-likes/:comment_like_id/relationships/comment(.:format)                  comment_likes#destroy_relationship {:relationship=>"comment"}
#                            comment_like_comment GET       /api/edge/comment-likes/:comment_like_id/comment(.:format)                                comments#get_related_resource {:relationship=>"comment", :source=>"comment_likes"}
#                 comment_like_relationships_user GET       /api/edge/comment-likes/:comment_like_id/relationships/user(.:format)                     comment_likes#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/comment-likes/:comment_like_id/relationships/user(.:format)                     comment_likes#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/comment-likes/:comment_like_id/relationships/user(.:format)                     comment_likes#destroy_relationship {:relationship=>"user"}
#                               comment_like_user GET       /api/edge/comment-likes/:comment_like_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"comment_likes"}
#                                                 GET       /api/edge/comment-likes(.:format)                                                         comment_likes#index
#                                                 POST      /api/edge/comment-likes(.:format)                                                         comment_likes#create
#                                    comment_like GET       /api/edge/comment-likes/:id(.:format)                                                     comment_likes#show
#                                                 PATCH     /api/edge/comment-likes/:id(.:format)                                                     comment_likes#update
#                                                 PUT       /api/edge/comment-likes/:id(.:format)                                                     comment_likes#update
#                                                 DELETE    /api/edge/comment-likes/:id(.:format)                                                     comment_likes#destroy
#                    report_relationships_naughty GET       /api/edge/reports/:report_id/relationships/naughty(.:format)                              reports#show_relationship {:relationship=>"naughty"}
#                                                 PUT|PATCH /api/edge/reports/:report_id/relationships/naughty(.:format)                              reports#update_relationship {:relationship=>"naughty"}
#                                                 DELETE    /api/edge/reports/:report_id/relationships/naughty(.:format)                              reports#destroy_relationship {:relationship=>"naughty"}
#                                  report_naughty GET       /api/edge/reports/:report_id/naughty(.:format)                                            naughties#get_related_resource {:relationship=>"naughty", :source=>"reports"}
#                       report_relationships_user GET       /api/edge/reports/:report_id/relationships/user(.:format)                                 reports#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/reports/:report_id/relationships/user(.:format)                                 reports#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/reports/:report_id/relationships/user(.:format)                                 reports#destroy_relationship {:relationship=>"user"}
#                                     report_user GET       /api/edge/reports/:report_id/user(.:format)                                               users#get_related_resource {:relationship=>"user", :source=>"reports"}
#                  report_relationships_moderator GET       /api/edge/reports/:report_id/relationships/moderator(.:format)                            reports#show_relationship {:relationship=>"moderator"}
#                                                 PUT|PATCH /api/edge/reports/:report_id/relationships/moderator(.:format)                            reports#update_relationship {:relationship=>"moderator"}
#                                                 DELETE    /api/edge/reports/:report_id/relationships/moderator(.:format)                            reports#destroy_relationship {:relationship=>"moderator"}
#                                report_moderator GET       /api/edge/reports/:report_id/moderator(.:format)                                          users#get_related_resource {:relationship=>"moderator", :source=>"reports"}
#                                         reports GET       /api/edge/reports(.:format)                                                               reports#index
#                                                 POST      /api/edge/reports(.:format)                                                               reports#create
#                                          report GET       /api/edge/reports/:id(.:format)                                                           reports#show
#                                                 PATCH     /api/edge/reports/:id(.:format)                                                           reports#update
#                                                 PUT       /api/edge/reports/:id(.:format)                                                           reports#update
#                                                 DELETE    /api/edge/reports/:id(.:format)                                                           reports#destroy
#                                        activity DELETE    /api/edge/activities/:id(.:format)                                                        activities#destroy
#                                                 GET       /api/edge/feeds/:group/:id(.:format)                                                      feeds#show
#                                                 POST      /api/edge/feeds/:group/:id/_read(.:format)                                                feeds#mark_read
#                                                 POST      /api/edge/feeds/:group/:id/_seen(.:format)                                                feeds#mark_seen
#                                                 DELETE    /api/edge/feeds/:group/:id/activities/:uuid(.:format)                                     feeds#destroy_activity
#                     group_relationships_members GET       /api/edge/groups/:group_id/relationships/members(.:format)                                groups#show_relationship {:relationship=>"members"}
#                                                 POST      /api/edge/groups/:group_id/relationships/members(.:format)                                groups#create_relationship {:relationship=>"members"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/members(.:format)                                groups#update_relationship {:relationship=>"members"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/members(.:format)                                groups#destroy_relationship {:relationship=>"members"}
#                                   group_members GET       /api/edge/groups/:group_id/members(.:format)                                              group_members#get_related_resources {:relationship=>"members", :source=>"groups"}
#                   group_relationships_neighbors GET       /api/edge/groups/:group_id/relationships/neighbors(.:format)                              groups#show_relationship {:relationship=>"neighbors"}
#                                                 POST      /api/edge/groups/:group_id/relationships/neighbors(.:format)                              groups#create_relationship {:relationship=>"neighbors"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/neighbors(.:format)                              groups#update_relationship {:relationship=>"neighbors"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/neighbors(.:format)                              groups#destroy_relationship {:relationship=>"neighbors"}
#                                 group_neighbors GET       /api/edge/groups/:group_id/neighbors(.:format)                                            group_neighbors#get_related_resources {:relationship=>"neighbors", :source=>"groups"}
#                     group_relationships_tickets GET       /api/edge/groups/:group_id/relationships/tickets(.:format)                                groups#show_relationship {:relationship=>"tickets"}
#                                                 POST      /api/edge/groups/:group_id/relationships/tickets(.:format)                                groups#create_relationship {:relationship=>"tickets"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/tickets(.:format)                                groups#update_relationship {:relationship=>"tickets"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/tickets(.:format)                                groups#destroy_relationship {:relationship=>"tickets"}
#                                   group_tickets GET       /api/edge/groups/:group_id/tickets(.:format)                                              group_tickets#get_related_resources {:relationship=>"tickets", :source=>"groups"}
#                     group_relationships_invites GET       /api/edge/groups/:group_id/relationships/invites(.:format)                                groups#show_relationship {:relationship=>"invites"}
#                                                 POST      /api/edge/groups/:group_id/relationships/invites(.:format)                                groups#create_relationship {:relationship=>"invites"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/invites(.:format)                                groups#update_relationship {:relationship=>"invites"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/invites(.:format)                                groups#destroy_relationship {:relationship=>"invites"}
#                                   group_invites GET       /api/edge/groups/:group_id/invites(.:format)                                              group_invites#get_related_resources {:relationship=>"invites", :source=>"groups"}
#                     group_relationships_reports GET       /api/edge/groups/:group_id/relationships/reports(.:format)                                groups#show_relationship {:relationship=>"reports"}
#                                                 POST      /api/edge/groups/:group_id/relationships/reports(.:format)                                groups#create_relationship {:relationship=>"reports"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/reports(.:format)                                groups#update_relationship {:relationship=>"reports"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/reports(.:format)                                groups#destroy_relationship {:relationship=>"reports"}
#                                   group_reports GET       /api/edge/groups/:group_id/reports(.:format)                                              group_reports#get_related_resources {:relationship=>"reports", :source=>"groups"}
#        group_relationships_leader_chat_messages GET       /api/edge/groups/:group_id/relationships/leader-chat-messages(.:format)                   groups#show_relationship {:relationship=>"leader_chat_messages"}
#                                                 POST      /api/edge/groups/:group_id/relationships/leader-chat-messages(.:format)                   groups#create_relationship {:relationship=>"leader_chat_messages"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/leader-chat-messages(.:format)                   groups#update_relationship {:relationship=>"leader_chat_messages"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/leader-chat-messages(.:format)                   groups#destroy_relationship {:relationship=>"leader_chat_messages"}
#                      group_leader_chat_messages GET       /api/edge/groups/:group_id/leader-chat-messages(.:format)                                 leader_chat_messages#get_related_resources {:relationship=>"leader_chat_messages", :source=>"groups"}
#                 group_relationships_action_logs GET       /api/edge/groups/:group_id/relationships/action-logs(.:format)                            groups#show_relationship {:relationship=>"action_logs"}
#                                                 POST      /api/edge/groups/:group_id/relationships/action-logs(.:format)                            groups#create_relationship {:relationship=>"action_logs"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/action-logs(.:format)                            groups#update_relationship {:relationship=>"action_logs"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/action-logs(.:format)                            groups#destroy_relationship {:relationship=>"action_logs"}
#                               group_action_logs GET       /api/edge/groups/:group_id/action-logs(.:format)                                          group_action_logs#get_related_resources {:relationship=>"action_logs", :source=>"groups"}
#                    group_relationships_category GET       /api/edge/groups/:group_id/relationships/category(.:format)                               groups#show_relationship {:relationship=>"category"}
#                                                 PUT|PATCH /api/edge/groups/:group_id/relationships/category(.:format)                               groups#update_relationship {:relationship=>"category"}
#                                                 DELETE    /api/edge/groups/:group_id/relationships/category(.:format)                               groups#destroy_relationship {:relationship=>"category"}
#                                  group_category GET       /api/edge/groups/:group_id/category(.:format)                                             group_categories#get_related_resource {:relationship=>"category", :source=>"groups"}
#                                          groups GET       /api/edge/groups(.:format)                                                                groups#index
#                                                 POST      /api/edge/groups(.:format)                                                                groups#create
#                                           group GET       /api/edge/groups/:id(.:format)                                                            groups#show
#                                                 PATCH     /api/edge/groups/:id(.:format)                                                            groups#update
#                                                 PUT       /api/edge/groups/:id(.:format)                                                            groups#update
#                                                 DELETE    /api/edge/groups/:id(.:format)                                                            groups#destroy
#                group_member_relationships_group GET       /api/edge/group-members/:group_member_id/relationships/group(.:format)                    group_members#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/group-members/:group_member_id/relationships/group(.:format)                    group_members#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/group-members/:group_member_id/relationships/group(.:format)                    group_members#destroy_relationship {:relationship=>"group"}
#                              group_member_group GET       /api/edge/group-members/:group_member_id/group(.:format)                                  groups#get_related_resource {:relationship=>"group", :source=>"group_members"}
#                 group_member_relationships_user GET       /api/edge/group-members/:group_member_id/relationships/user(.:format)                     group_members#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-members/:group_member_id/relationships/user(.:format)                     group_members#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-members/:group_member_id/relationships/user(.:format)                     group_members#destroy_relationship {:relationship=>"user"}
#                               group_member_user GET       /api/edge/group-members/:group_member_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"group_members"}
#          group_member_relationships_permissions GET       /api/edge/group-members/:group_member_id/relationships/permissions(.:format)              group_members#show_relationship {:relationship=>"permissions"}
#                                                 POST      /api/edge/group-members/:group_member_id/relationships/permissions(.:format)              group_members#create_relationship {:relationship=>"permissions"}
#                                                 PUT|PATCH /api/edge/group-members/:group_member_id/relationships/permissions(.:format)              group_members#update_relationship {:relationship=>"permissions"}
#                                                 DELETE    /api/edge/group-members/:group_member_id/relationships/permissions(.:format)              group_members#destroy_relationship {:relationship=>"permissions"}
#                        group_member_permissions GET       /api/edge/group-members/:group_member_id/permissions(.:format)                            group_permissions#get_related_resources {:relationship=>"permissions", :source=>"group_members"}
#                group_member_relationships_notes GET       /api/edge/group-members/:group_member_id/relationships/notes(.:format)                    group_members#show_relationship {:relationship=>"notes"}
#                                                 POST      /api/edge/group-members/:group_member_id/relationships/notes(.:format)                    group_members#create_relationship {:relationship=>"notes"}
#                                                 PUT|PATCH /api/edge/group-members/:group_member_id/relationships/notes(.:format)                    group_members#update_relationship {:relationship=>"notes"}
#                                                 DELETE    /api/edge/group-members/:group_member_id/relationships/notes(.:format)                    group_members#destroy_relationship {:relationship=>"notes"}
#                              group_member_notes GET       /api/edge/group-members/:group_member_id/notes(.:format)                                  group_member_notes#get_related_resources {:relationship=>"notes", :source=>"group_members"}
#                                                 GET       /api/edge/group-members(.:format)                                                         group_members#index
#                                                 POST      /api/edge/group-members(.:format)                                                         group_members#create
#                                    group_member GET       /api/edge/group-members/:id(.:format)                                                     group_members#show
#                                                 PATCH     /api/edge/group-members/:id(.:format)                                                     group_members#update
#                                                 PUT       /api/edge/group-members/:id(.:format)                                                     group_members#update
#                                                 DELETE    /api/edge/group-members/:id(.:format)                                                     group_members#destroy
#     group_permission_relationships_group_member GET       /api/edge/group-permissions/:group_permission_id/relationships/group-member(.:format)     group_permissions#show_relationship {:relationship=>"group_member"}
#                                                 PUT|PATCH /api/edge/group-permissions/:group_permission_id/relationships/group-member(.:format)     group_permissions#update_relationship {:relationship=>"group_member"}
#                                                 DELETE    /api/edge/group-permissions/:group_permission_id/relationships/group-member(.:format)     group_permissions#destroy_relationship {:relationship=>"group_member"}
#                   group_permission_group_member GET       /api/edge/group-permissions/:group_permission_id/group-member(.:format)                   group_members#get_related_resource {:relationship=>"group_member", :source=>"group_permissions"}
#                               group_permissions GET       /api/edge/group-permissions(.:format)                                                     group_permissions#index
#                                                 POST      /api/edge/group-permissions(.:format)                                                     group_permissions#create
#                                group_permission GET       /api/edge/group-permissions/:id(.:format)                                                 group_permissions#show
#                                                 PATCH     /api/edge/group-permissions/:id(.:format)                                                 group_permissions#update
#                                                 PUT       /api/edge/group-permissions/:id(.:format)                                                 group_permissions#update
#                                                 DELETE    /api/edge/group-permissions/:id(.:format)                                                 group_permissions#destroy
#             group_neighbor_relationships_source GET       /api/edge/group-neighbors/:group_neighbor_id/relationships/source(.:format)               group_neighbors#show_relationship {:relationship=>"source"}
#                                                 PUT|PATCH /api/edge/group-neighbors/:group_neighbor_id/relationships/source(.:format)               group_neighbors#update_relationship {:relationship=>"source"}
#                                                 DELETE    /api/edge/group-neighbors/:group_neighbor_id/relationships/source(.:format)               group_neighbors#destroy_relationship {:relationship=>"source"}
#                           group_neighbor_source GET       /api/edge/group-neighbors/:group_neighbor_id/source(.:format)                             groups#get_related_resource {:relationship=>"source", :source=>"group_neighbors"}
#        group_neighbor_relationships_destination GET       /api/edge/group-neighbors/:group_neighbor_id/relationships/destination(.:format)          group_neighbors#show_relationship {:relationship=>"destination"}
#                                                 PUT|PATCH /api/edge/group-neighbors/:group_neighbor_id/relationships/destination(.:format)          group_neighbors#update_relationship {:relationship=>"destination"}
#                                                 DELETE    /api/edge/group-neighbors/:group_neighbor_id/relationships/destination(.:format)          group_neighbors#destroy_relationship {:relationship=>"destination"}
#                      group_neighbor_destination GET       /api/edge/group-neighbors/:group_neighbor_id/destination(.:format)                        groups#get_related_resource {:relationship=>"destination", :source=>"group_neighbors"}
#                                                 GET       /api/edge/group-neighbors(.:format)                                                       group_neighbors#index
#                                                 POST      /api/edge/group-neighbors(.:format)                                                       group_neighbors#create
#                                  group_neighbor GET       /api/edge/group-neighbors/:id(.:format)                                                   group_neighbors#show
#                                                 PATCH     /api/edge/group-neighbors/:id(.:format)                                                   group_neighbors#update
#                                                 PUT       /api/edge/group-neighbors/:id(.:format)                                                   group_neighbors#update
#                                                 DELETE    /api/edge/group-neighbors/:id(.:format)                                                   group_neighbors#destroy
#                                group_categories GET       /api/edge/group-categories(.:format)                                                      group_categories#index
#                                                 POST      /api/edge/group-categories(.:format)                                                      group_categories#create
#                                                 GET       /api/edge/group-categories/:id(.:format)                                                  group_categories#show
#                                                 PATCH     /api/edge/group-categories/:id(.:format)                                                  group_categories#update
#                                                 PUT       /api/edge/group-categories/:id(.:format)                                                  group_categories#update
#                                                 DELETE    /api/edge/group-categories/:id(.:format)                                                  group_categories#destroy
#                 group_ticket_relationships_user GET       /api/edge/group-tickets/:group_ticket_id/relationships/user(.:format)                     group_tickets#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-tickets/:group_ticket_id/relationships/user(.:format)                     group_tickets#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-tickets/:group_ticket_id/relationships/user(.:format)                     group_tickets#destroy_relationship {:relationship=>"user"}
#                               group_ticket_user GET       /api/edge/group-tickets/:group_ticket_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"group_tickets"}
#                group_ticket_relationships_group GET       /api/edge/group-tickets/:group_ticket_id/relationships/group(.:format)                    group_tickets#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/group-tickets/:group_ticket_id/relationships/group(.:format)                    group_tickets#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/group-tickets/:group_ticket_id/relationships/group(.:format)                    group_tickets#destroy_relationship {:relationship=>"group"}
#                              group_ticket_group GET       /api/edge/group-tickets/:group_ticket_id/group(.:format)                                  groups#get_related_resource {:relationship=>"group", :source=>"group_tickets"}
#             group_ticket_relationships_assignee GET       /api/edge/group-tickets/:group_ticket_id/relationships/assignee(.:format)                 group_tickets#show_relationship {:relationship=>"assignee"}
#                                                 PUT|PATCH /api/edge/group-tickets/:group_ticket_id/relationships/assignee(.:format)                 group_tickets#update_relationship {:relationship=>"assignee"}
#                                                 DELETE    /api/edge/group-tickets/:group_ticket_id/relationships/assignee(.:format)                 group_tickets#destroy_relationship {:relationship=>"assignee"}
#                           group_ticket_assignee GET       /api/edge/group-tickets/:group_ticket_id/assignee(.:format)                               users#get_related_resource {:relationship=>"assignee", :source=>"group_tickets"}
#             group_ticket_relationships_messages GET       /api/edge/group-tickets/:group_ticket_id/relationships/messages(.:format)                 group_tickets#show_relationship {:relationship=>"messages"}
#                                                 POST      /api/edge/group-tickets/:group_ticket_id/relationships/messages(.:format)                 group_tickets#create_relationship {:relationship=>"messages"}
#                                                 PUT|PATCH /api/edge/group-tickets/:group_ticket_id/relationships/messages(.:format)                 group_tickets#update_relationship {:relationship=>"messages"}
#                                                 DELETE    /api/edge/group-tickets/:group_ticket_id/relationships/messages(.:format)                 group_tickets#destroy_relationship {:relationship=>"messages"}
#                           group_ticket_messages GET       /api/edge/group-tickets/:group_ticket_id/messages(.:format)                               group_ticket_messages#get_related_resources {:relationship=>"messages", :source=>"group_tickets"}
#        group_ticket_relationships_first_message GET       /api/edge/group-tickets/:group_ticket_id/relationships/first-message(.:format)            group_tickets#show_relationship {:relationship=>"first_message"}
#                                                 PUT|PATCH /api/edge/group-tickets/:group_ticket_id/relationships/first-message(.:format)            group_tickets#update_relationship {:relationship=>"first_message"}
#                                                 DELETE    /api/edge/group-tickets/:group_ticket_id/relationships/first-message(.:format)            group_tickets#destroy_relationship {:relationship=>"first_message"}
#                      group_ticket_first_message GET       /api/edge/group-tickets/:group_ticket_id/first-message(.:format)                          group_ticket_messages#get_related_resource {:relationship=>"first_message", :source=>"group_tickets"}
#                                                 GET       /api/edge/group-tickets(.:format)                                                         group_tickets#index
#                                                 POST      /api/edge/group-tickets(.:format)                                                         group_tickets#create
#                                    group_ticket GET       /api/edge/group-tickets/:id(.:format)                                                     group_tickets#show
#                                                 PATCH     /api/edge/group-tickets/:id(.:format)                                                     group_tickets#update
#                                                 PUT       /api/edge/group-tickets/:id(.:format)                                                     group_tickets#update
#                                                 DELETE    /api/edge/group-tickets/:id(.:format)                                                     group_tickets#destroy
#       group_ticket_message_relationships_ticket GET       /api/edge/group-ticket-messages/:group_ticket_message_id/relationships/ticket(.:format)   group_ticket_messages#show_relationship {:relationship=>"ticket"}
#                                                 PUT|PATCH /api/edge/group-ticket-messages/:group_ticket_message_id/relationships/ticket(.:format)   group_ticket_messages#update_relationship {:relationship=>"ticket"}
#                                                 DELETE    /api/edge/group-ticket-messages/:group_ticket_message_id/relationships/ticket(.:format)   group_ticket_messages#destroy_relationship {:relationship=>"ticket"}
#                     group_ticket_message_ticket GET       /api/edge/group-ticket-messages/:group_ticket_message_id/ticket(.:format)                 group_tickets#get_related_resource {:relationship=>"ticket", :source=>"group_ticket_messages"}
#         group_ticket_message_relationships_user GET       /api/edge/group-ticket-messages/:group_ticket_message_id/relationships/user(.:format)     group_ticket_messages#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-ticket-messages/:group_ticket_message_id/relationships/user(.:format)     group_ticket_messages#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-ticket-messages/:group_ticket_message_id/relationships/user(.:format)     group_ticket_messages#destroy_relationship {:relationship=>"user"}
#                       group_ticket_message_user GET       /api/edge/group-ticket-messages/:group_ticket_message_id/user(.:format)                   users#get_related_resource {:relationship=>"user", :source=>"group_ticket_messages"}
#                                                 GET       /api/edge/group-ticket-messages(.:format)                                                 group_ticket_messages#index
#                                                 POST      /api/edge/group-ticket-messages(.:format)                                                 group_ticket_messages#create
#                            group_ticket_message GET       /api/edge/group-ticket-messages/:id(.:format)                                             group_ticket_messages#show
#                                                 PATCH     /api/edge/group-ticket-messages/:id(.:format)                                             group_ticket_messages#update
#                                                 PUT       /api/edge/group-ticket-messages/:id(.:format)                                             group_ticket_messages#update
#                                                 DELETE    /api/edge/group-ticket-messages/:id(.:format)                                             group_ticket_messages#destroy
#                group_report_relationships_group GET       /api/edge/group-reports/:group_report_id/relationships/group(.:format)                    group_reports#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/group-reports/:group_report_id/relationships/group(.:format)                    group_reports#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/group-reports/:group_report_id/relationships/group(.:format)                    group_reports#destroy_relationship {:relationship=>"group"}
#                              group_report_group GET       /api/edge/group-reports/:group_report_id/group(.:format)                                  groups#get_related_resource {:relationship=>"group", :source=>"group_reports"}
#              group_report_relationships_naughty GET       /api/edge/group-reports/:group_report_id/relationships/naughty(.:format)                  group_reports#show_relationship {:relationship=>"naughty"}
#                                                 PUT|PATCH /api/edge/group-reports/:group_report_id/relationships/naughty(.:format)                  group_reports#update_relationship {:relationship=>"naughty"}
#                                                 DELETE    /api/edge/group-reports/:group_report_id/relationships/naughty(.:format)                  group_reports#destroy_relationship {:relationship=>"naughty"}
#                            group_report_naughty GET       /api/edge/group-reports/:group_report_id/naughty(.:format)                                naughties#get_related_resource {:relationship=>"naughty", :source=>"group_reports"}
#                 group_report_relationships_user GET       /api/edge/group-reports/:group_report_id/relationships/user(.:format)                     group_reports#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-reports/:group_report_id/relationships/user(.:format)                     group_reports#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-reports/:group_report_id/relationships/user(.:format)                     group_reports#destroy_relationship {:relationship=>"user"}
#                               group_report_user GET       /api/edge/group-reports/:group_report_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"group_reports"}
#            group_report_relationships_moderator GET       /api/edge/group-reports/:group_report_id/relationships/moderator(.:format)                group_reports#show_relationship {:relationship=>"moderator"}
#                                                 PUT|PATCH /api/edge/group-reports/:group_report_id/relationships/moderator(.:format)                group_reports#update_relationship {:relationship=>"moderator"}
#                                                 DELETE    /api/edge/group-reports/:group_report_id/relationships/moderator(.:format)                group_reports#destroy_relationship {:relationship=>"moderator"}
#                          group_report_moderator GET       /api/edge/group-reports/:group_report_id/moderator(.:format)                              users#get_related_resource {:relationship=>"moderator", :source=>"group_reports"}
#                                                 GET       /api/edge/group-reports(.:format)                                                         group_reports#index
#                                                 POST      /api/edge/group-reports(.:format)                                                         group_reports#create
#                                    group_report GET       /api/edge/group-reports/:id(.:format)                                                     group_reports#show
#                                                 PATCH     /api/edge/group-reports/:id(.:format)                                                     group_reports#update
#                                                 PUT       /api/edge/group-reports/:id(.:format)                                                     group_reports#update
#                                                 DELETE    /api/edge/group-reports/:id(.:format)                                                     group_reports#destroy
#                   group_ban_relationships_group GET       /api/edge/group-bans/:group_ban_id/relationships/group(.:format)                          group_bans#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/group-bans/:group_ban_id/relationships/group(.:format)                          group_bans#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/group-bans/:group_ban_id/relationships/group(.:format)                          group_bans#destroy_relationship {:relationship=>"group"}
#                                 group_ban_group GET       /api/edge/group-bans/:group_ban_id/group(.:format)                                        groups#get_related_resource {:relationship=>"group", :source=>"group_bans"}
#                    group_ban_relationships_user GET       /api/edge/group-bans/:group_ban_id/relationships/user(.:format)                           group_bans#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-bans/:group_ban_id/relationships/user(.:format)                           group_bans#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-bans/:group_ban_id/relationships/user(.:format)                           group_bans#destroy_relationship {:relationship=>"user"}
#                                  group_ban_user GET       /api/edge/group-bans/:group_ban_id/user(.:format)                                         users#get_related_resource {:relationship=>"user", :source=>"group_bans"}
#               group_ban_relationships_moderator GET       /api/edge/group-bans/:group_ban_id/relationships/moderator(.:format)                      group_bans#show_relationship {:relationship=>"moderator"}
#                                                 PUT|PATCH /api/edge/group-bans/:group_ban_id/relationships/moderator(.:format)                      group_bans#update_relationship {:relationship=>"moderator"}
#                                                 DELETE    /api/edge/group-bans/:group_ban_id/relationships/moderator(.:format)                      group_bans#destroy_relationship {:relationship=>"moderator"}
#                             group_ban_moderator GET       /api/edge/group-bans/:group_ban_id/moderator(.:format)                                    users#get_related_resource {:relationship=>"moderator", :source=>"group_bans"}
#                                      group_bans GET       /api/edge/group-bans(.:format)                                                            group_bans#index
#                                                 POST      /api/edge/group-bans(.:format)                                                            group_bans#create
#                                       group_ban GET       /api/edge/group-bans/:id(.:format)                                                        group_bans#show
#                                                 PATCH     /api/edge/group-bans/:id(.:format)                                                        group_bans#update
#                                                 PUT       /api/edge/group-bans/:id(.:format)                                                        group_bans#update
#                                                 DELETE    /api/edge/group-bans/:id(.:format)                                                        group_bans#destroy
#    group_member_note_relationships_group_member GET       /api/edge/group-member-notes/:group_member_note_id/relationships/group-member(.:format)   group_member_notes#show_relationship {:relationship=>"group_member"}
#                                                 PUT|PATCH /api/edge/group-member-notes/:group_member_note_id/relationships/group-member(.:format)   group_member_notes#update_relationship {:relationship=>"group_member"}
#                                                 DELETE    /api/edge/group-member-notes/:group_member_note_id/relationships/group-member(.:format)   group_member_notes#destroy_relationship {:relationship=>"group_member"}
#                  group_member_note_group_member GET       /api/edge/group-member-notes/:group_member_note_id/group-member(.:format)                 group_members#get_related_resource {:relationship=>"group_member", :source=>"group_member_notes"}
#            group_member_note_relationships_user GET       /api/edge/group-member-notes/:group_member_note_id/relationships/user(.:format)           group_member_notes#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-member-notes/:group_member_note_id/relationships/user(.:format)           group_member_notes#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-member-notes/:group_member_note_id/relationships/user(.:format)           group_member_notes#destroy_relationship {:relationship=>"user"}
#                          group_member_note_user GET       /api/edge/group-member-notes/:group_member_note_id/user(.:format)                         users#get_related_resource {:relationship=>"user", :source=>"group_member_notes"}
#                                                 GET       /api/edge/group-member-notes(.:format)                                                    group_member_notes#index
#                                                 POST      /api/edge/group-member-notes(.:format)                                                    group_member_notes#create
#                               group_member_note GET       /api/edge/group-member-notes/:id(.:format)                                                group_member_notes#show
#                                                 PATCH     /api/edge/group-member-notes/:id(.:format)                                                group_member_notes#update
#                                                 PUT       /api/edge/group-member-notes/:id(.:format)                                                group_member_notes#update
#                                                 DELETE    /api/edge/group-member-notes/:id(.:format)                                                group_member_notes#destroy
#         leader_chat_message_relationships_group GET       /api/edge/leader-chat-messages/:leader_chat_message_id/relationships/group(.:format)      leader_chat_messages#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/leader-chat-messages/:leader_chat_message_id/relationships/group(.:format)      leader_chat_messages#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/leader-chat-messages/:leader_chat_message_id/relationships/group(.:format)      leader_chat_messages#destroy_relationship {:relationship=>"group"}
#                       leader_chat_message_group GET       /api/edge/leader-chat-messages/:leader_chat_message_id/group(.:format)                    groups#get_related_resource {:relationship=>"group", :source=>"leader_chat_messages"}
#          leader_chat_message_relationships_user GET       /api/edge/leader-chat-messages/:leader_chat_message_id/relationships/user(.:format)       leader_chat_messages#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/leader-chat-messages/:leader_chat_message_id/relationships/user(.:format)       leader_chat_messages#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/leader-chat-messages/:leader_chat_message_id/relationships/user(.:format)       leader_chat_messages#destroy_relationship {:relationship=>"user"}
#                        leader_chat_message_user GET       /api/edge/leader-chat-messages/:leader_chat_message_id/user(.:format)                     users#get_related_resource {:relationship=>"user", :source=>"leader_chat_messages"}
#                            leader_chat_messages GET       /api/edge/leader-chat-messages(.:format)                                                  leader_chat_messages#index
#                                                 POST      /api/edge/leader-chat-messages(.:format)                                                  leader_chat_messages#create
#                             leader_chat_message GET       /api/edge/leader-chat-messages/:id(.:format)                                              leader_chat_messages#show
#                                                 PATCH     /api/edge/leader-chat-messages/:id(.:format)                                              leader_chat_messages#update
#                                                 PUT       /api/edge/leader-chat-messages/:id(.:format)                                              leader_chat_messages#update
#                                                 DELETE    /api/edge/leader-chat-messages/:id(.:format)                                              leader_chat_messages#destroy
#             group_action_log_relationships_user GET       /api/edge/group-action-logs/:group_action_log_id/relationships/user(.:format)             group_action_logs#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-action-logs/:group_action_log_id/relationships/user(.:format)             group_action_logs#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-action-logs/:group_action_log_id/relationships/user(.:format)             group_action_logs#destroy_relationship {:relationship=>"user"}
#                           group_action_log_user GET       /api/edge/group-action-logs/:group_action_log_id/user(.:format)                           users#get_related_resource {:relationship=>"user", :source=>"group_action_logs"}
#            group_action_log_relationships_group GET       /api/edge/group-action-logs/:group_action_log_id/relationships/group(.:format)            group_action_logs#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/group-action-logs/:group_action_log_id/relationships/group(.:format)            group_action_logs#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/group-action-logs/:group_action_log_id/relationships/group(.:format)            group_action_logs#destroy_relationship {:relationship=>"group"}
#                          group_action_log_group GET       /api/edge/group-action-logs/:group_action_log_id/group(.:format)                          groups#get_related_resource {:relationship=>"group", :source=>"group_action_logs"}
#           group_action_log_relationships_target GET       /api/edge/group-action-logs/:group_action_log_id/relationships/target(.:format)           group_action_logs#show_relationship {:relationship=>"target"}
#                                                 PUT|PATCH /api/edge/group-action-logs/:group_action_log_id/relationships/target(.:format)           group_action_logs#update_relationship {:relationship=>"target"}
#                                                 DELETE    /api/edge/group-action-logs/:group_action_log_id/relationships/target(.:format)           group_action_logs#destroy_relationship {:relationship=>"target"}
#                         group_action_log_target GET       /api/edge/group-action-logs/:group_action_log_id/target(.:format)                         targets#get_related_resource {:relationship=>"target", :source=>"group_action_logs"}
#                                                 GET       /api/edge/group-action-logs(.:format)                                                     group_action_logs#index
#                                                 POST      /api/edge/group-action-logs(.:format)                                                     group_action_logs#create
#                                group_action_log GET       /api/edge/group-action-logs/:id(.:format)                                                 group_action_logs#show
#                                                 PATCH     /api/edge/group-action-logs/:id(.:format)                                                 group_action_logs#update
#                                                 PUT       /api/edge/group-action-logs/:id(.:format)                                                 group_action_logs#update
#                                                 DELETE    /api/edge/group-action-logs/:id(.:format)                                                 group_action_logs#destroy
#                 group_invite_relationships_user GET       /api/edge/group-invites/:group_invite_id/relationships/user(.:format)                     group_invites#show_relationship {:relationship=>"user"}
#                                                 PUT|PATCH /api/edge/group-invites/:group_invite_id/relationships/user(.:format)                     group_invites#update_relationship {:relationship=>"user"}
#                                                 DELETE    /api/edge/group-invites/:group_invite_id/relationships/user(.:format)                     group_invites#destroy_relationship {:relationship=>"user"}
#                               group_invite_user GET       /api/edge/group-invites/:group_invite_id/user(.:format)                                   users#get_related_resource {:relationship=>"user", :source=>"group_invites"}
#                group_invite_relationships_group GET       /api/edge/group-invites/:group_invite_id/relationships/group(.:format)                    group_invites#show_relationship {:relationship=>"group"}
#                                                 PUT|PATCH /api/edge/group-invites/:group_invite_id/relationships/group(.:format)                    group_invites#update_relationship {:relationship=>"group"}
#                                                 DELETE    /api/edge/group-invites/:group_invite_id/relationships/group(.:format)                    group_invites#destroy_relationship {:relationship=>"group"}
#                              group_invite_group GET       /api/edge/group-invites/:group_invite_id/group(.:format)                                  groups#get_related_resource {:relationship=>"group", :source=>"group_invites"}
#               group_invite_relationships_sender GET       /api/edge/group-invites/:group_invite_id/relationships/sender(.:format)                   group_invites#show_relationship {:relationship=>"sender"}
#                                                 PUT|PATCH /api/edge/group-invites/:group_invite_id/relationships/sender(.:format)                   group_invites#update_relationship {:relationship=>"sender"}
#                                                 DELETE    /api/edge/group-invites/:group_invite_id/relationships/sender(.:format)                   group_invites#destroy_relationship {:relationship=>"sender"}
#                             group_invite_sender GET       /api/edge/group-invites/:group_invite_id/sender(.:format)                                 users#get_related_resource {:relationship=>"sender", :source=>"group_invites"}
#                                                 GET       /api/edge/group-invites(.:format)                                                         group_invites#index
#                                                 POST      /api/edge/group-invites(.:format)                                                         group_invites#create
#                                    group_invite GET       /api/edge/group-invites/:id(.:format)                                                     group_invites#show
#                                                 PATCH     /api/edge/group-invites/:id(.:format)                                                     group_invites#update
#                                                 PUT       /api/edge/group-invites/:id(.:format)                                                     group_invites#update
#                                                 DELETE    /api/edge/group-invites/:id(.:format)                                                     group_invites#destroy
#                                                 POST      /api/edge/group-invites/:id/_accept(.:format)                                             group_invites#accept
#                                                 POST      /api/edge/group-invites/:id/_decline(.:format)                                            group_invites#decline
#                                                 POST      /api/edge/group-invites/:id/_revoke(.:format)                                             group_invites#revoke
#                                                 GET       /api/edge/groups/:id/_stats(.:format)                                                     groups#stats
#                                                 POST      /api/edge/groups/:id/_read(.:format)                                                      groups#read
#                                       sso_canny GET       /api/edge/sso/canny(.:format)                                                             sso#canny
#                                     rails_admin           /api/admin                                                                                RailsAdmin::Engine
#                                     sidekiq_web           /api/sidekiq                                                                              Sidekiq::Web
#                                           admin GET       /api/admin(.:format)                                                                      sessions#redirect
#                                         sidekiq GET       /api/sidekiq(.:format)                                                                    sessions#redirect
#                                        sessions POST      /api/sessions(.:format)                                                                   sessions#create
#                                     new_session GET       /api/sessions/new(.:format)                                                               sessions#new
#                                  debug_dump_all GET       /api/debug/dump_all(.:format)                                                             debug#dump_all
#                                  debug_trace_on POST      /api/debug/trace_on(.:format)                                                             debug#trace_on
#                                   debug_gc_info GET       /api/debug/gc_info(.:format)                                                              debug#gc_info
#                                   hooks_youtube GET       /api/hooks/youtube(.:format)                                                              webhooks#youtube_verify
#                                                 POST      /api/hooks/youtube(.:format)                                                              webhooks#youtube_notify
#                                  user__prodsync POST      /api/user/_prodsync(.:format)                                                             users#prod_sync
#                                                 GET       /api/oauth/authorize/:code(.:format)                                                      doorkeeper/authorizations#show
#                             oauth_authorization GET       /api/oauth/authorize(.:format)                                                            doorkeeper/authorizations#new
#                                                 POST      /api/oauth/authorize(.:format)                                                            doorkeeper/authorizations#create
#                                                 DELETE    /api/oauth/authorize(.:format)                                                            doorkeeper/authorizations#destroy
#                                     oauth_token POST      /api/oauth/token(.:format)                                                                doorkeeper/tokens#create
#                                    oauth_revoke POST      /api/oauth/revoke(.:format)                                                               doorkeeper/tokens#revoke
#                              oauth_applications GET       /api/oauth/applications(.:format)                                                         doorkeeper/applications#index
#                                                 POST      /api/oauth/applications(.:format)                                                         doorkeeper/applications#create
#                           new_oauth_application GET       /api/oauth/applications/new(.:format)                                                     doorkeeper/applications#new
#                          edit_oauth_application GET       /api/oauth/applications/:id/edit(.:format)                                                doorkeeper/applications#edit
#                               oauth_application GET       /api/oauth/applications/:id(.:format)                                                     doorkeeper/applications#show
#                                                 PATCH     /api/oauth/applications/:id(.:format)                                                     doorkeeper/applications#update
#                                                 PUT       /api/oauth/applications/:id(.:format)                                                     doorkeeper/applications#update
#                                                 DELETE    /api/oauth/applications/:id(.:format)                                                     doorkeeper/applications#destroy
#                   oauth_authorized_applications GET       /api/oauth/authorized_applications(.:format)                                              doorkeeper/authorized_applications#index
#                    oauth_authorized_application DELETE    /api/oauth/authorized_applications/:id(.:format)                                          doorkeeper/authorized_applications#destroy
#                                oauth_token_info GET       /api/oauth/token/info(.:format)                                                           doorkeeper/token_info#show
#                                            root GET       /api(.:format)                                                                            home#index
#
# Routes for RailsAdmin::Engine:
#    dashboard GET         /                                      rails_admin/main#dashboard
#        index GET|POST    /:model_name(.:format)                 rails_admin/main#index
#          new GET|POST    /:model_name/new(.:format)             rails_admin/main#new
#       export GET|POST    /:model_name/export(.:format)          rails_admin/main#export
#  bulk_delete POST|DELETE /:model_name/bulk_delete(.:format)     rails_admin/main#bulk_delete
#  bulk_action POST        /:model_name/bulk_action(.:format)     rails_admin/main#bulk_action
#         show GET         /:model_name/:id(.:format)             rails_admin/main#show
#         edit GET|PUT     /:model_name/:id/edit(.:format)        rails_admin/main#edit
#       delete GET|DELETE  /:model_name/:id/delete(.:format)      rails_admin/main#delete
# history_show GET         /:model_name/:id/history(.:format)     rails_admin/main#history_show
#  show_in_app GET         /:model_name/:id/show_in_app(.:format) rails_admin/main#show_in_app
#
