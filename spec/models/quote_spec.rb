# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: quotes
#
#  id             :integer          not null, primary key
#  character_name :string(255)      not null
#  content        :text             not null
#  likes_count    :integer          default(0), not null
#  media_type     :string           not null, indexed => [media_id]
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  character_id   :integer          indexed
#  media_id       :integer          not null, indexed, indexed => [media_type]
#  user_id        :integer
#
# Indexes
#
#  index_quotes_on_character_id             (character_id)
#  index_quotes_on_media_id                 (media_id)
#  index_quotes_on_media_id_and_media_type  (media_id,media_type)
#
# Foreign Keys
#
#  fk_rails_bd0c2ee7f3  (character_id => characters.id)
#
# rubocop:enable Metrics/LineLength

require 'rails_helper'

RSpec.describe Quote, type: :model do
  subject { build(:quote) }

  it { should belong_to(:user).counter_cache(true).required }
  it { should belong_to(:media).required }
  it { should have_many(:likes).class_name('QuoteLike') }

end
