class MangadexImport
  attr_reader :file_location

  LANGUAGES = {
    'arabic' => 'ar',
    'bulgarian' => 'bg',
    'burmese' => 'my',
    'catalan' => 'ca',
    'chinese (trad)' => 'zh_Hant',
    'chinese (simp)' => 'zh_Hans',
    'english' => 'en',
    'filipino' => 'fil',
    'french' => 'fr',
    'german' => 'de',
    'hungarian' => 'hu',
    'indonesian' => 'id_in',
    'italian' => 'it',
    'japanese' => 'en_jp',
    # 'japanese' => 'ja_jp',
    'korean' => 'ko',
    'malay' => 'ms',
    'persian' => 'fa',
    'polish' => 'pl',
    'portuguese (br)' => 'pt_br',
    'portuguese (pt)' => 'pt',
    'romanian' => 'ro',
    'russian' => 'ru',
    'spanish' => 'es',
    'spanish (es)' => 'es',
    'spanish (latem)' => 'es',
    'thai' => 'th',
    'turkish' => 'tr',
    'vietnamese' => 'vi'
  }.freeze

  # ideally pass in location here?
  def initialize(file_location = nil)
    @file_location = file_location || 'tmp/mangadex_import/manga-batch-1-temp.ndjson'
  end

  def import!
    each_mangadex_entry do |data, name, mal_id|
      kitsu_id = kitsu_id_by_mal_id(mal_id) if mal_id.present?

      if kitsu_id.blank?
        kitsu_id = kitsu_id_by_name(name)
        validate_kitsu_id(kitsu_id)
      end

      puts "Kitsu Id: #{kitsu_id}"

      row = Row.new(kitsu_data(kitsu_id), data)
      row.create_or_update
    end
  end

  def each_mangadex_entry
    File.foreach(file_location) do |line|
      line = JSON.parse(line)
      name = line['title']['name']
      mal_id = formatted_mal_id(line.dig('external_links', 'MyAnimeList'))

      yield line, name, mal_id
    end
  end

  def formatted_mal_id(url)
    return nil if url.blank?

    url.split('/').last
  end

  def validate_kitsu_id(kitsu_id)
    # I am not sure what to really validate this on
    # we already know subtype is correct.
  end

  private

  def kitsu_id_by_mal_id(mal_id)
    Mapping.where(
      external_site: 'myanimelist/manga',
      external_id: mal_id
    ).first&.item_id
  end

  # Will attemp to find the Kitsu Manga by id
  #
  # This is kind of inefficient because we then get this again
  # Using Manga.where in #kitsu_data(kitsu_id)
  #
  # @param name [String] title of manga from mangadex data
  # @return [Int, nil] kitsu id if it exists
  def kitsu_id_by_name(name)
    Mapping.guess(
      'manga',
      title: name,
      subtype: 'NOT subtype:novel'
    )&.id
  end

  def kitsu_data(kitsu_id)
    Manga.where(id: kitsu_id).first_or_initialize
  end
end
