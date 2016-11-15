module SearchableResource
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :chewy_index, :queryable_fields

    # Declare the Chewy index to use when searching this resource
    def index(index)
      @chewy_index = index
    end

    def inherited(subclass)
      subclass.instance_variable_set(:@chewy_index, @chewy_index.deep_dup)
      subclass.instance_variable_set(:@queryable_fields,
        @queryable_fields.deep_dup)
      super
    end

    # Declare the fields to query, and how to query them
    def query(field, opts = {})
      field = field.to_sym

      # For some reason, #filter(verify:) is supposed to return the values to
      # use.  I cannot honestly figure out why this is the case, so we provide
      # #query(valid:) instead.  #query(valid:) lambdas receive a value+context
      # and return a boolean.  If all values in a field are valid, the whole
      # is assumed valid.
      #
      # If you must, you can still use #filter(verify:) to handle the entire
      # array all at once, or to modify values.
      filter field, verify: opts[:verify] || -> (values, context) {
        if opts[:valid]
          values if values.all? { |v| opts[:valid].call(v, context) }
        else
          values
        end
      }

      @queryable_fields ||= {}
      @queryable_fields[field] = opts
    end

    # Determine if an ElasticSearch hit is required
    def should_query?(filters)
      @queryable_fields ||= {}
      filters.keys.any? { |key| @queryable_fields.include?(key) }
    end

    # Override the #find method to search when called upon
    def find_records(filters, opts = {})
      return super(filters, opts) unless should_query?(filters)
      return [] if filters.values.any?(&:nil?)

      # Apply scopes and load
      apply_scopes(filters, opts).load
    end

    # Count all search results
    def find_count(filters, opts = {})
      return super(filters, opts) unless should_query?(filters)
      return 0 if filters.values.any?(&:nil?)
      apply_scopes(filters, opts).total_count
    end

    # Allow sorting on anything queryable + _score
    def sortable_fields(context = nil)
      @queryable_fields ||= {}
      if is_searchable?
        super(context) + @queryable_fields.keys + ['_score']
      else
        super(context)
      end
    end

    def is_searchable?
      @queryable_fields.present?
    end

    private

    def apply_scopes(filters, opts = {})
      # TODO: actually apply policy somehow
      opts[:context][:policy_used]&.call
      # Generate query
      query = generate_query(filters)
      query = query.reduce(@chewy_index) do |scope, subquery|
        scope.public_send(*subquery.values_at(:mode, :query))
      end
      # Pagination
      query = opts[:paginator].apply(query, {}) if opts[:paginator]
      # Sorting
      if opts[:sort_criteria]
        query = opts[:sort_criteria].reduce(query) do |scope, sort|
          field = (sort[:field] == 'id') ? '_score' : sort[:field]
          scope.order(field => sort[:direction])
        end
      else
        query = query.order('_score' => :desc)
      end
      query
    end

    def generate_query(filters)
      # For each queryable field, attempt to apply.  If there's no apply
      # specified, use auto_query to generate one.
      queries = @queryable_fields.map do |field, opts|
        next unless filters.key?(field) # Skip if we don't have a filter

        filter = filters[field]
        filter = opts[:apply].call(filter, {}) if opts[:apply]

        { mode: opts[:mode] || :filter, query: auto_query(field, filter) }
      end
      queries.compact
    end

    def auto_query(field, value)
      case value
      when String, Fixnum, Float, Date
        { match: { field => value } }
      when Range
        { range: { field => { gte: value.min, lte: value.max } } }
      when Array
        # Array<String|Fixnum|Float> get shorthanded to a single match query
        if value.all? { |v| v.is_a?(String) || v.is_a?(Numeric) }
          auto_query(field, value.join(' '))
        else
          matchers = value.map { |v| auto_query(field, v) }
          { bool: { should: matchers } }
        end
      else
        value
      end
    end
  end
end
