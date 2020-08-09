# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: genres
#
#  id          :integer          not null, primary key
#  description :text
#  name        :string(255)
#  slug        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# rubocop:enable Metrics/LineLength

FactoryBot.define do
  factory :genre do
    # TODO: switch to Faker::Book.genre when they make a new release
    name { Faker::Book.genre }
    description { { en: Faker::Lorem.sentence } }
  end
end
