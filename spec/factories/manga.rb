# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: manga
#
#  id                        :integer          not null, primary key
#  abbreviated_titles        :string           is an Array
#  age_rating                :integer
#  age_rating_guide          :string
#  average_rating            :float
#  canonical_title           :string           default("en_jp"), not null
#  chapter_count             :integer
#  cover_image_content_type  :string(255)
#  cover_image_file_name     :string(255)
#  cover_image_file_size     :integer
#  cover_image_processing    :boolean
#  cover_image_top_offset    :integer          default(0)
#  cover_image_updated_at    :datetime
#  end_date                  :date
#  favorites_count           :integer          default(0), not null
#  popularity_rank           :integer
#  poster_image_content_type :string(255)
#  poster_image_file_name    :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  rating_frequencies        :hstore           default({}), not null
#  rating_rank               :integer
#  serialization             :string(255)
#  slug                      :string(255)
#  start_date                :date
#  status                    :integer
#  subtype                   :integer          default(1), not null
#  synopsis                  :text
#  titles                    :hstore           default({}), not null
#  user_count                :integer          default(0), not null
#  volume_count              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# rubocop:enable Metrics/LineLength

FactoryGirl.define do
  factory :manga do
    titles { { en_jp: Faker::Name.name } }
    canonical_title 'en_jp'
    average_rating { rand(1.0..100.0) }
  end
end
