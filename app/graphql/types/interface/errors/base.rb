module Types::Interface::Errors::Base
  include Types::Interface::Base
  description 'Generic error fields used by all errors.'

  field :message, String,
    null: false,
    description: 'A description of the error'

  field :path, [String],
    null: true,
    description: 'Which input value this error came from'

  field :code, String,
    null: true,
    description: 'The error code.'
end
