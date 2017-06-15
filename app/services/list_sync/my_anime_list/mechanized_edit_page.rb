module ListSync
  class MyAnimeList
    module MechanizedEditPage
      extend ActiveSupport::Concern

      included do
        attr_reader :agent, :media
      end

      def initialize(agent, media)
        @agent = agent
        @media = media
      end

      private

      def check_authentication!
        if edit_page.uri.to_s.include?('login.php')
          raise ListSync::AuthenticationError
        end
      end

      def edit_page
        return @edit_page if @edit_page
        url = "https://myanimelist.net/ownlist/#{media_kind}/#{mal_id}/edit"
        @edit_page = @agent.get(url)
      end

      def csrf_token
        edit_page.search('meta[name="csrf_token"]').first['content']
      end

      def mal_id
        @mal_id ||= media.mapping_for("myanimelist/#{media_kind}")&.external_id
      end

      def media_kind
        media.class.name.underscore
      end
    end
  end
end
