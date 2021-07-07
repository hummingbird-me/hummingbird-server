class MangadexImport
  class Chapter1
    def initialize(kitsu_chapter, mangadex_chapter)
      @kitsu_chapter = kitsu_chapter
      @mangadex_chapter = mangadex_chapter
    end

    def create_or_update!
      @kitsu_chapter.volume ||= mangadex_volume
      @kitsu_chapter.titles = mangadex_chapter_titles
      @kitsu_chapter.canonical_title ||= mangadex_canonical_title if @kitsu_chapter.titles.present?

      @kitsu_chapter.save!
    end

    def mangadex_volume
      volume_number = @mangadex_chapter['volume']
      return if volume_number.blank?

      Volume.where(manga_id: @kitsu_chapter.manga_id, number: volume_number).first_or_initialize
    end

    def mangadex_chapter_titles
      kitsu_titles = @kitsu_chapter.titles.compact

      @mangadex_chapter['alt_titles']&.compact&.each do |title, value|
        kitsu_titles[MangadexImport::LANGUAGES[title]] ||= value
      end

      kitsu_titles
    end

    def mangadex_canonical_title
      @kitsu_chapter.titles.keys.first
    end
  end
end
