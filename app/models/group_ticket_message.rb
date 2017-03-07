# == Schema Information
#
# Table name: group_ticket_messages
#
#  id                :integer          not null, primary key
#  content           :text             not null
#  content_formatted :text             not null
#  kind              :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ticket_id         :integer          not null, indexed
#  user_id           :integer          not null
#
# Indexes
#
#  index_group_ticket_messages_on_ticket_id  (ticket_id)
#
# Foreign Keys
#
#  fk_rails_e77fcefb97  (ticket_id => group_tickets.id)
#

class GroupTicketMessage < ApplicationRecord
  include ContentProcessable

  belongs_to :ticket, class_name: 'GroupTicket', required: true
  belongs_to :user, required: true

  enum kind: %i[message mod_note]
  processable :content, InlinePipeline

  scope :visible_for, ->(user) {
    joins(:ticket).merge(GroupTicket.visible_for(user))
  }
end
