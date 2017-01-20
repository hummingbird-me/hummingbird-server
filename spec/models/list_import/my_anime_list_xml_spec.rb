# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: list_imports
#
#  id                      :integer          not null, primary key
#  error_message           :text
#  error_trace             :text
#  input_file_content_type :string
#  input_file_file_name    :string
#  input_file_file_size    :integer
#  input_file_updated_at   :datetime
#  input_text              :text
#  progress                :integer
#  status                  :integer          default(0), not null
#  strategy                :integer          not null
#  total                   :integer
#  type                    :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer          not null
#
# rubocop:enable Metrics/LineLength

require 'rails_helper'

RSpec.describe ListImport::MyAnimeListXML do
  let(:file) { Fixture.new('list_import/my_anime_list/nuck.xml.gz').to_file }
  it { should validate_absence_of(:input_text) }
  it { should have_attached_file(:input_file) }
  it { should validate_attachment_presence(:input_file) }
  it do
    expect(subject).to validate_attachment_content_type(:input_file)
      .allowing('application/gzip', 'application/xml')
      .rejecting('application/zip', 'application/x-rar-compressed')
  end

  context 'with a list' do
    subject do
      ListImport::MyAnimeListXML.create(
        input_file: file,
        strategy: :greater,
        user: build(:user)
      )
    end

    describe '#count' do
      it 'should return the total number of entries' do
        expect(subject.count).to eq(109)
      end
    end

    describe '#each' do
      it 'should yield at least 100 times' do
        expect { |b|
          subject.each(&b)
        }.to yield_control.at_least(100)
      end
    end
  end
end
