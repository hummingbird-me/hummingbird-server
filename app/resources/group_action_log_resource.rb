class GroupActionLogResource < BaseResource
  attributes :created_at, :verb

  has_one :user
  has_one :group
  has_one :target, polymorphic: true

  filter :group
end
