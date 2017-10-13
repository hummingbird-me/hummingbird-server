# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: volumes
#
#  id         :integer          not null, primary key
#  isbn       :string           not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  manga_id   :integer          not null, indexed
#
# Indexes
#
#  index_volumes_on_manga_id  (manga_id)
#
# Foreign Keys
#
#  fk_rails_4ab5f3f2e5  (manga_id => manga.id)
#
# rubocop:enable Metrics/LineLength

require 'rails_helper'

RSpec.describe Volume, type: :model do
  subject { build(:volume) }
  it { should belong_to(:manga) }
  it { should have_many(:chapters) }
end
