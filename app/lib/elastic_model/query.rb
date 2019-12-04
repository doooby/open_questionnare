module ElasticModel
  class Query

    attr_reader :body

    def initialize model_proxy
      @proxy = model_proxy
      @only_ids = true
      @body = {
          query: { bool: {} },
          _source: [:_id]
      }
    end

    def full_source
      body.delete :_source
      self
    end

    def explain
      body[:explain] = true
      self
    end

    def track_scores
      body[:track_scores] = true
      self
    end

    def add_filter field
      (query_bool[:filter] ||= []).push field
      self
    end

    def add_id_filter id
      add_filter({term: {_id: id}})
      self
    end

    def add_must field
      (query_bool[:must] ||= []).push field
      self
    end

    def sort *fields
      body[:sort] = fields.map do |field|
        # asc is default

        case field
          when Array
            field, order = field
            order ? {field.to_sym => order} : field

          else
            field

        end
      end
      self
    end

    def paginate page, per_page=nil
      page, per_page = normalize_pagination page, per_page
      @pagination = [page, per_page]

      body[:size] = per_page
      body[:from] = per_page * (page - 1)
      self
    end

    def next_page!
      raise 'not paginated' unless @pagination
      page, per_page = @pagination
      paginate page + 1, per_page
    end

    def before_search &block
      @before_search = block
      self
    end

    def with_search &block
      @with_search = block
      self
    end

    def to_fetch callable
      @to_fetch = callable
      self
    end

    def search
      @before_search.(self) if @before_search
      es_result = @proxy.search body.to_json
      @with_search.(es_result, self) if @with_search
      es_result
    end

    def fetch_records
      response = search
      ids = dig_ids response
      records = get_records_by_ids ids

      page, per_page = (@pagination ||= [1, records.length])
      total_count = response['hits']['total']['value']
      Slice.new records, page, per_page, total_count
    end

    private

    def query_bool
      @query_bool ||= body[:query][:bool]
    end

    def normalize_pagination page, per_page
      page = (page.presence || 1).to_i
      per_page = (per_page.presence || 10).to_i
      [page, per_page]
    end

    def dig_ids response
      id = '_id'
      response['hits']['hits'].map{|hit| hit[id].to_i}
    end

    def get_records_by_ids ids
      return [] if ids.empty?

      records = if @to_fetch
        @proxy.model.class_exec ids, &@to_fetch
      else
        @proxy.model.where "id IN(#{ids.join ','})"
      end

      # original order
      index = records.to_a.each_with_object({}){|r, i| i[r.id] = r}
      ids.map{|id| index[id]}.compact
    end

    class Slice < ::Array

      attr_reader :current_page, :per_page, :total_count

      def initialize arr, page, per_page, total
        @current_page = page
        @per_page = per_page
        @total_count = total
        super arr
      end

      def more?
        total_count > (current_page - 1) * per_page + length
      end

    end

  end
end
