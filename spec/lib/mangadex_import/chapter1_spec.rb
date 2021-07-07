require 'rails_helper'

RSpec.describe MangadexImport::Chapter1 do
  let(:mangadex_chapter) { JSON.parse(fixture('mangadex_import/mangadex-chapter.json')) }
  let(:kitsu_new_chapter) { Chapter.new(manga_id: 1) }

  context 'new chapter' do
    subject { described_class.new(kitsu_new_chapter, mangadex_chapter) }

    describe '#mangadex_volume' do
      it 'should return nil if no volume exists' do
        mangadex_chapter['volume'] = nil
        expect(subject.mangadex_volume).to be_nil
      end

      it 'should return a volume if the volume exists' do
        volume = subject.mangadex_volume

        expect(volume).to be_a(Volume)
        expect(volume.number).to eq(1)
      end
    end

    describe '#mangadex_chapter_titles' do
      it 'should combine with current titles' do
        random_title = 'Test'
        kitsu_new_chapter.titles = { 'en_jp' => random_title }

        combined_titles = kitsu_new_chapter.titles
        combined_titles['en'] = 'Cat'

        expect(subject.mangadex_chapter_titles.size).to eq(2)
        expect(subject.mangadex_chapter_titles).to eq(combined_titles)
      end

      it 'should not overwrite any titles that exist' do
        random_title = 'Test'
        kitsu_new_chapter.titles = { 'en' => random_title }

        expect(subject.mangadex_chapter_titles.size).to eq(1)
        expect(subject.mangadex_chapter_titles['en']).to eq(random_title)
      end

      it 'should combine if no kitsu titles present' do
        expect(subject.mangadex_chapter_titles.size).to eq(1)
        expect(subject.mangadex_chapter_titles).to eq('en' => 'Cat')
      end
    end
  end
end
