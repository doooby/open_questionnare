module ElasticModel
  class Proxy

    attr_reader :model, :queries, :index_name, :client

    def initialize model, client
      @model = model
      @client = client
      @index_name = "#{EmaWeb.env}_#{model.name.underscore.gsub '/', '_'}"
      @queries = Object.new
    end

    def inspect
      "#<ElasticModel::Proxy model=#{@model.name}>"
    end

    def define_index settings:, mappings:, **_
      @index_settings = settings
      @index_mappings = mappings
    end

    def create_index
      client.indices.create(
          index: index_name,
          body: {
              settings: @index_settings,
              mappings: @index_mappings,
          }
      )
    end

    def rebuild_index
      client.indices.delete(
          index: index_name,
          ignore: [404]
      )

      create_index
    end

    def refresh_index
      client.indices.refresh(
          index: index_name
      )
    end

    def index_document id, document
      client.index(
          index: index_name,
          id: id,
          body: document
      )
    end

    def delete_document id
      client.delete(
          index: index_name,
          id: id
      )
    end

    def index_documents records
      body = records.map do |record|
        {
            index: {
                _index: index_name,
                _id: record.id,
                data: record.to_elastic_document
            }
        }
      end
      client.bulk body: body
    end

    def get_document id
      result = Elastic::Query.new(self).
          full_source.
          add_id_filter(id).
          search

      hit = result['hits']['hits'].first
      hit && hit['_source']
    end

    def search body
      client.search(
          index: index_name,
          body: body
      )
    end

    def query
      Elastic::Query.new self
    end

    def define_queries &block
      es_proxy = self
      queries.define_singleton_method(:new_query){ es_proxy.query }
      queries.instance_exec &block
      queries.freeze
    end

    ###

    def self.test_mode!
      unless @test_mode_activated
        @test_mode_activated = true
        prepend TestStub
      end
    end

    module TestStub
      ENABLED = Set.new

      def self.with_enabled *models
        models.each{|m| TestStub::ENABLED.add m}
        yield
      ensure
        models.each{|m| TestStub::ENABLED.delete m}
      end

      def self.disable_all
        ENABLED.clear
      end

      def enable
        ENABLED.add model
      end

      def disable
        ENABLED.delete model
      end

      def enabled?
        ENABLED.include? model
      end

      def with_enabled &block
        ModelProxy.with_enabled model, &block
      end

      def prepare_with_records records=model.all
        enable
        rebuild_index
        index_documents records
        refresh_index
      end

      def index_document *_
        super if enabled?
      end

      def delete_document *_
        super if enabled?
      end

      def index_documents *_
        super if enabled?
      end

    end

  end
end
