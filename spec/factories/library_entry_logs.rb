# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: library_entry_logs
#
#  id                :integer          not null, primary key
#  action_performed  :string           default("create"), not null
#  error_message     :text
#  media_type        :string
#  progress          :integer
#  rating            :decimal(2, 1)
#  reconsume_count   :integer
#  reconsuming       :boolean
#  status            :integer
#  sync_status       :integer          default(0), not null
#  volumes_owned     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  linked_account_id :integer          not null, indexed
#  media_id          :integer
#
# Indexes
#
#  index_library_entry_logs_on_linked_account_id  (linked_account_id)
#
# rubocop:enable Metrics/LineLength

FactoryGirl.define do
  factory :library_entry_log do
    association :linked_account, strategy: :build
    action_performed 'create'
    sync_status 0
  end
end
