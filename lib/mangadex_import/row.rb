class MangadexImport
  class Row
    CATEGORY_MAPPINGS = {
      '4-koma' => '',
      'award-winning' => '',
      'doujinshi' => '',
      'drama' => '',
      'game' => '',
      'isekai' => '',
      'medical' => '',
      'oneshot' => '',
      'sci-fi' => 'science-fiction',
      'shoujo' => 'shoujou',
      'slice-of-life' => '',
      'smut' => '',
      'webtoon' => ''
    }.freeze

    CATEGORY_SKIPS = %w[[no chapters]].freeze

    attr_reader :kitsu_data, :mangadex_data

    def initialize(kitsu_data, mangadex_data)
      @kitsu_data = kitsu_data
      @mangadex_data = mangadex_data
    end

    def create_or_update
      kitsu_generic_fields.each do |kitsu_field|
        @kitsu_data[kitsu_field] ||= public_send("mangadex_#{kitsu_field}")
      end

      kitsu_custom_fields.each do |kitsu_field|
        public_send("mangadex_#{kitsu_field}")
      end

      @kitsu_data.save!
      kitsu_after_manga_save_fields.each do |kitsu_field|
        public_send("mangadex_#{kitsu_field}")
      end
    end

    def kitsu_generic_fields
      %w[
        age_rating canonical_title
        end_date original_locale
        serialization slug start_date synopsis
        volume_count
      ]
    end

    def kitsu_custom_fields
      %w[
        abbreviated_titles chapter_count titles categories subtype
      ]
    end

    def kitsu_after_manga_save_fields
      %w[
        author artist chapters poster_image
      ]
    end

    def mangadex_age_rating
      mangadex_data['hentai'] ? 'R18' : nil
    end

    def mangadex_abbreviated_titles
      kitsu_data.abbreviated_titles ||= []
      kitsu_data.abbreviated_titles.concat(mangadex_data['alt_titles']).uniq!
    end

    def mangadex_canonical_title
      MangadexImport::LANGUAGES[mangadex_original_locale&.downcase]
    end

    def mangadex_chapter_count
      # reset kitsu chapter count if at 0
      kitsu_data.chapter_count = nil if kitsu_data.chapter_count&.zero?
      # set the variable to 0 if kitsu chapter count is nil
      kitsu_chapter_count = kitsu_data.chapter_count || 0
      mangadex_data['total_chapters'] ||= 0

      @kitsu_data.chapter_count = [kitsu_chapter_count, mangadex_data['total_chapters']].max
    end

    def mangadex_original_locale
      mangadex_data['title']['origin']
    end

    def mangadex_poster_image
      @kitsu_data.poster_image = mangadex_data['thumbnail'] if @kitsu_data.poster_image.blank?
    end

    def mangadex_serialization
      nil
    end

    def mangadex_slug
      mangadex_data['title']['slug']
    end

    def mangadex_subtype
      # When using first_or_initialize it sets default to 'novel'
      # yeah... idk who thought that would be a good idea in a Manga table....
      # p.s: to the guy who set default to 1... arrays are 0 index based.
      @kitsu_data.subtype = 'manga' if kitsu_data.new_record?
    end

    # TODO: do we need to sanitize?
    def mangadex_synopsis
      mangadex_data['description']
    end

    def mangadex_titles
      @kitsu_data.titles['en_jp'] ||= mangadex_data['title']['name']
    end

    def mangadex_volume_count
      nil
    end

    def mangadex_start_date
      nil
    end

    def mangadex_end_date
      nil
    end

    def mangadex_categories
      mangadex_data['genre_tags'].each do |category_name|
        next if CATEGORY_SKIPS.include?(category_name)

        category_slug = mapped_mangadex_category(category_name)

        # skip if this category already exists in the association array.
        next if kitsu_data.categories.find { |cat| cat.slug == category_slug }

        category = Category.find_by(slug: category_slug)
        # NOTE: I don't think this works the way I intended.
        # I was thinking that we can just do save at the end and it will save
        # the associations.
        @kitsu_data.categories << category
      end
    end

    def mangadex_author
      author = mangadex_data['author']
      return if author.blank?

      mangadex_staff(author)
    end

    def mangadex_artist
      artist = mangadex_data['artist']
      return if artist.blank?

      mangadex_staff(artist)
    end

    def mangadex_staff(name)
      staff = Person.create_with(
        canonical_name: 'en',
        names: { 'en' => name }
      ).find_or_create_by(name: name)

      MangaStaff.find_or_create_by(person_id: staff.id, manga_id: kitsu_data.id)
    end

    # I am thinking of moving everything chapte related to another class.
    def mangadex_chapters
      return if mangadex_data['chapters'].blank?

      mangadex_data['chapters'].each do |mangadex_chapter|
        kitsu_chapter = kitsu_data.chapters.where(number: mangadex_chapter['chapter']).first_or_initialize
        chapter = MangadexImport::Chapter1.new(kitsu_chapter, mangadex_chapter)
        chapter.create_or_update!
      end
    end

    private

    def mapped_mangadex_category(category)
      category = category.tr(' ', '-').downcase
      return CATEGORY_MAPPINGS[category] if CATEGORY_MAPPINGS.key?(category)
      category
    end
  end
end
