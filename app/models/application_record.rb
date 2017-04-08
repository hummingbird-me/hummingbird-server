class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  WHITELISTED_ADMIN_FIELDS = %w[episode_count chapter_count volume_count].freeze

  def stream_id
    "#{self.class.name}:#{self.id}"
  end

  def self.paperclip_definitions
    attachment_definitions
  end

  def self.created_today
    where(created_at: Date.today..Date.tomorrow)
  end

  def self.inherited(subclass)
    super(subclass)
    subclass.rails_admin do
      edit do
        exclude_fields do |field|
          name = field.name.to_s
          suffixed = %w[_count _processing _rank _formatted].any? do |suffix|
            name.end_with?(suffix)
          end
          suffixed && !WHITELISTED_ADMIN_FIELDS.include?(name)
        end
        exclude_fields :created_at, :updated_at
      end
    end
  end
end
