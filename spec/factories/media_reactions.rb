# == Schema Information
#
# Table name: media_reactions
#
#  id               :integer          not null, primary key
#  media_type       :string           not null, indexed => [media_id, user_id]
#  progress         :integer          default(0), not null
#  reaction         :string(140)
#  up_votes_count   :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  anime_id         :integer          indexed
#  drama_id         :integer          indexed
#  library_entry_id :integer          indexed
#  manga_id         :integer          indexed
#  media_id         :integer          not null, indexed => [media_type, user_id]
#  user_id          :integer          indexed => [media_type, media_id], indexed
#
# Indexes
#
#  index_media_reactions_on_anime_id                             (anime_id)
#  index_media_reactions_on_drama_id                             (drama_id)
#  index_media_reactions_on_library_entry_id
#                                                        (library_entry_id)
#  index_media_reactions_on_manga_id                             (manga_id)
#  index_media_reactions_on_media_type_and_media_id_and_user_id
#                                      (media_type,media_id,user_id) UNIQUE
#  index_media_reactions_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_08b3ced6d4  (user_id => users.id)
#  fk_rails_77e29e3c45  (drama_id => dramas.id)
#  fk_rails_9a5bef4caf  (manga_id => manga.id)
#  fk_rails_bbc29d526d  (library_entry_id => library_entries.id)
#  fk_rails_db814b132f  (anime_id => anime.id)
#

FactoryGirl.define do
  factory :media_reaction do
    reaction { Faker::Lorem.characters(140) }
    association :anime, factory: :anime, strategy: :build
    association :library_entry, factory: :library_entry,
                                progress: 1, strategy: :build
    association :user, factory: :user, strategy: :build
  end
end
