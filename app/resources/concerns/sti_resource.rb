module STIResource
  extend ActiveSupport::Concern

  def kind
    _model.type.demodulize.underscore.dasherize
  end

  def kind=(val)
    _model.type = "#{self.class._model_name}::#{val.underscore.classify}"
  end

  included do
    attribute :kind
    filter :kind, apply: ->(records, values, _options) {
      prefix = self.class._model_name
      kinds = values.map { |v| "#{prefix}::#{v.underscore.classify}" }
      records.where(type: kinds)
    }
  end
end
