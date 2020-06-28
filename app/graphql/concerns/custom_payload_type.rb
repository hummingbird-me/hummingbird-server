module CustomPayloadType
  extend ActiveSupport::Concern

  CRUD_OPERATION = %w[create update delete].freeze

  class_methods do
    # NOTE: Hook Override - https://github.com/rmosolgo/graphql-ruby/issues/2737
    def generate_payload_type
      resolver_name = generate_resolver_name
      resolver_fields = fields

      Class.new(object_class) do
        graphql_name("#{resolver_name}Payload")
        description("Auto-generated return type of #{resolver_name}")

        # You may override this default error field by defining
        # your own error field in the mutation
        if resolver_fields.keys.exclude?('errors')
          field :errors, [Types::Errors::Generic],
            null: true,
            description: 'Graphql Errors'
        end

        resolver_fields.each do |_name, f|
          # Reattach the already-defined field here
          # (The field's `.owner` will still point to the mutation, not the object type, I think)
          add_field(f)
        end
      end
    end

    def generate_resolver_name
      return graphql_name if CRUD_OPERATION.exclude?(graphql_name.downcase)

      # Mutations::Anime::Create -> AnimeCreate
      name.split('::')[1..-1].join
    end
  end
end
