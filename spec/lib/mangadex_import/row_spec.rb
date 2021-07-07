require 'rails_helper'

RSpec.describe MangadexImport::Row do
  let(:mangadex_data_regular) { JSON.parse(fixture('mangadex_import/manga-batch-1-temp.ndjson')) }
  let(:mangadex_data_hentai) { JSON.parse(fixture('mangadex_import/mangadex-hentai.ndjson')) }
  # let(:kitsu_data) { JSON.parse(fixture('mangadex_import/kitsu_data/kyou-wa-kaisha-yasumimasu.json')) }
  let(:kitsu_new_entry) { Manga.new }

  context 'new entry' do
    subject { described_class.new(kitsu_new_entry, mangadex_data_regular) }

    describe '#mangadex_age_rating' do
      it 'should return R18 for hentai' do
        subject = described_class.new(kitsu_new_entry, mangadex_data_hentai)

        expect(subject.mangadex_age_rating).to eq('R18')
      end

      it 'should return nil for non-hentai' do
        expect(subject.mangadex_age_rating).to be_nil
      end
    end

    describe '#mangadex_abbreviated_titles' do
      it 'should combine with current titles' do
        random_title = 'something cool'
        # need to set default for now.
        kitsu_new_entry.abbreviated_titles = []
        kitsu_new_entry.abbreviated_titles << random_title
        subject.mangadex_abbreviated_titles

        combined_titles = subject.mangadex_data['alt_titles']
        combined_titles << random_title

        expect(subject.kitsu_data.abbreviated_titles.size).to eq(8)
        expect(subject.kitsu_data.abbreviated_titles).to match_array(combined_titles)
      end

      it 'should combine if no kitsu titles present' do
        subject.mangadex_abbreviated_titles

        expect(subject.kitsu_data.abbreviated_titles.size).to eq(7)
        expect(subject.kitsu_data.abbreviated_titles).to eq(subject.mangadex_data['alt_titles'])
      end
    end

    describe '#mangadex_canonical_title' do
      it 'should return the proper language iso code' do
        expect(subject.mangadex_canonical_title).to eq('en_jp')
      end

      it 'should return nil if origin is nil' do
        mangadex_data_regular['title']['origin'] = nil

        expect(subject.mangadex_canonical_title).to be_nil
      end

      it 'should return nil if no origin key' do
        mangadex_data_regular['title'].delete('origin')

        expect(subject.mangadex_canonical_title).to be_nil
      end
    end

    describe '#mangadex_chapter_count' do
      it 'should update kitsu data to max total chapters' do
        expect(subject.mangadex_chapter_count).to eq(3)
      end

      it 'should update kitsu data to max total chapters when at 0' do
        kitsu_new_entry.chapter_count = 0
        expect(subject.mangadex_chapter_count).to eq(3)
      end

      it 'should keep use the higher number for max total chapters' do
        kitsu_new_entry.chapter_count = 10
        expect(subject.mangadex_chapter_count).to eq(10)
      end
    end

    describe '#mangadex_original_locale' do
      it 'should return when present' do
        expect(subject.mangadex_original_locale).to eq('Japanese')
      end
    end

    describe '#mangadex_poster_image' do
      it 'should update if poster image does not exist' do
        stub_request(:get, 'https://mangadex.org/images/manga/12091.jpg').to_return(status: 200)
        subject.mangadex_poster_image

        expect(subject.kitsu_data.poster_image_file_name).to eq('12091.jpg')
      end
    end

    describe '#mangadex_serialization' do
      it 'should always return nil because it does not exist' do
        expect(subject.mangadex_serialization).to be_nil
      end
    end

    describe '#mangadex_slug' do
      it 'should return when present' do
        expect(subject.mangadex_slug).to eq('sayonara-sorcier')
      end
    end

    describe '#mangadex_subtype' do
      it 'should return manga for new record' do
        expect(subject.mangadex_subtype).to eq('manga')
      end
    end

    describe '#mangadex_synopsis' do
      it 'should return when present' do
        expect(subject.mangadex_synopsis).to match(/In the late/)
      end
    end

    describe '#mangadex_volume_count' do
      it 'should return nil' do
        expect(subject.mangadex_volume_count).to be_nil
      end
    end

    describe '#mangadex_start_date' do
      it 'should return nil' do
        expect(subject.mangadex_start_date).to be_nil
      end
    end

    describe '#mangadex_end_date' do
      it 'should return nil' do
        expect(subject.mangadex_end_date).to be_nil
      end
    end

    describe '#mangadex_author' do
      # not sure how to test
    end

    describe '#mangadex_artist' do
      # not sure how to test
    end
  end
end
