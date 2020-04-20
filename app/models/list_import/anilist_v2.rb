# frozen_string_literal: true

class ListImport
  class AnilistV2 < ListImport
    GRAPHQL_API = 'https://graphql.anilist.co'.freeze

    # accepts a username as input
    validates :input_text, length: {
      minimum: 3,
      maximum: 20
    }, presence: true
    # does not accept file uploads
    validates :input_file, absence: true
    validate :ensure_user_exists, on: :create

    def ensure_user_exists
      return false if input_text.blank?
      return true if user_exists?

      errors.add(:input_text, "AniList user not found - #{input_text}")
    end

    def count
      anime_list.count + manga_list.count
    end

    def each
      %w[anime manga].each do |type|
        send("#{type}_list").each do |media|
          row = Row.new(media, type)

          yield row.media_mapping, row.data
        end
      end
    end

    private

    def anime_list
      media_lists.data.anime.lists.map(&:entries).flatten
    end

    def manga_list
      media_lists.data.manga.lists.map(&:entries).flatten
    end

    def user_exists?
      @user_exists ||= media_lists&.errors&.detect { |error| error.last.include?('404') }.blank?
    end

    def media_lists
      @media_lists ||= client.query(media_lists_query)
    end

    def media_lists_query
      @media_lists_query ||= client.parse <<-'GRAPHQL'
        {
          anime: MediaListCollection(userName: input_text, type: ANIME) {
            lists {
              name
              entries {
                score
                status
                repeat
                progress
                progressVolumes
                notes
                startedAt {
                  year
                  month
                  day
                }
                completedAt {
                  year
                  month
                  day
                }
                media {
                  id
                  idMal
                  title {
                    romaji
                    english
                    native
                    userPreferred
                  }
                }
              }
            }
          },
          manga: MediaListCollection(userName: input_text, type: MANGA) {
            lists {
              name
              entries {
                score
                status
                repeat
                progress
                progressVolumes
                notes
                startedAt {
                  year
                  month
                  day
                }
                completedAt {
                  year
                  month
                  day
                }
                media {
                  id
                  idMal
                  title {
                    romaji
                    english
                    native
                    userPreferred
                  }
                }
              }
            }
          }
        }
      GRAPHQL
    end

    def client
      @client ||= GraphQL::Client.new(schema: schema, execute: http)
    end

    def http
      @http ||= GraphQL::Client::HTTP.new(GRAPHQL_API) do
        def headers(context)
          { 'Content-Type': 'application/json' }
        end
      end
    end

    def schema
      @schema ||= GraphQL::Client.load_schema(http)
    end
  end
end
