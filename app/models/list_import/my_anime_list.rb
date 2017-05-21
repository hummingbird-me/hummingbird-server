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

class ListImport
  class MyAnimeList < ListImport
    MAL_HOST = 'https://myanimelist.net'.freeze

    # Only accept usernames, not XML exports
    validates :input_text, presence: true
    validates :input_file, absence: true
    validate :ensure_list_is_public, on: :create

    def count
      data.length
    end

    def ensure_list_is_public
      %w[anime manga].each do |kind|
        request = Typhoeus::Request.get("#{MAL_HOST}/#{kind}list/#{input_text}")
        case request.code
        when 403
          errors.add(:input_text,
            "Your MyAnimeList #{kind} list must be public to import")
        when 404
          errors.add(:input_text, 'MyAnimeList user not found')
        end
      end
    end

    def each
      data.each do |row|
        row = Row.new(row)
        yield row.media, row.data
      end
    end

    private

    def data
      @data ||= %w[animelist mangalist].map { |l| list(l) }.reduce(&:+)
    end

    def list(list)
      loop.with_index.reduce([]) do |data, (_, index)|
        page = get(list, index)
        break data if page.blank?
        data + page
      end
    end

    def get(list, page)
      request = Typhoeus::Request.get(build_url(list, page))
      JSON.parse(request.body)
    end

    def build_url(list, page)
      offset = page * 300
      "#{MAL_HOST}/#{list}/#{input_text}/load.json?offset=#{offset}&status=7"
    end
  end
end
