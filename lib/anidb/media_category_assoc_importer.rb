class AnidbAssocMediaCategoryImport
  class ImportFile
    attr_reader :data

    def initialize(base_media_url, anime_assoc_file, genre_map_file)
      # Loading the JSON
      utc = Time.now.to_i.to_s
      anime_json_file = open(
        base_media_url +
        anime_assoc_file +
        '?' +
        utc
      ).read
      @data = JSON.parse(anime_json_file)
      genre_categeory_map = open(
        base_media_url +
        genre_map_file +
        '?' +
        utc
      ).read
      gc_data = JSON.parse(genre_categeory_map)
      gc_data.update(gc_data) { |_, v| Category.where(title: v)[0] if v }
      @genre_category_model = gc_data
    end

    def associate_media_categores(media)
      genres = media.genres.map(&:name)
      return unless genres.empty?
      categories = genres.map { |g|
        @genre_category_model[g]
      }.compact
      if categories
        media.categories = categories
        media.save
      end
    end

    def associate_manga!
      puts 'Associating Manga Categories From Kitsu Genre Map'
      manga = Manga.includes(:genres).all
      manga.each do |m|
        associate_media_categores(m)
      end
    end

    def associate_empty_anime(exclude_ids)
      puts 'Associating Excluded Anime With Categories From Kitsu Genre Map'
      anime = Anime.includes(:genres).where.not(id: exclude_ids)
      anime.each do |a|
        associate_media_categores(a)
      end
    end

    def associate_initial_anime!
      exclude_ids = []
      puts 'Associating Anime With Categories From AniDB Dump'
      data.each do |unfiltered_anime|
        unfiltered_anime = unfiltered_anime.deep_symbolize_keys
        next unless unfiltered_anime[:tags]
        mapping_object = {
          title: unfiltered_anime[:canonical],
          episode_count: unfiltered_anime[:episode_count]
        }
        puts 'looking up -> ' + unfiltered_anime[:canonical]
        kitsu_anime = Mapping.guess('Anime', mapping_object)
        next unless kitsu_anime
        puts '      >found<'
        categories = Category.where(anidb_id: unfiltered_anime[:tags])
        kitsu_anime.categories = categories
        kitsu_anime.save
        exclude_ids << kitsu_anime.id
      end
      exclude_ids
    end

    def apply!
      associate_manga!
      excluded_anime_ids = associate_initial_anime!
      associate_empty_anime(excluded_anime_ids)
    end
  end

  def run!
    ActiveRecord::Base.logger = Logger.new(nil)
    Chewy.strategy(:bypass)
    base_media_url = 'https://media.kitsu.io/import_files/'
    anime_filename = 'anidb_anime_category_assoc.json'
    genre_map_filename = 'kitsu_anidb_genre_category_map.json'
    ImportFile.new(base_media_url, anime_filename, genre_map_filename).apply!
  end
end
