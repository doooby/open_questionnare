module ElasticModel
  extend ActiveSupport::Concern

  def elastic_index!
    self.class.elastic.index_document id, to_elastic_document
  end

  def elastic_delete!
    self.class.elastic.delete_document id
  end

  class_methods do
    def elastic
      @elastic_proxy ||= ModelProxy.new(self, Elastic.client)
    end
  end

  def self.client
    @client ||= begin
      host = ConfigStore.from('elasticsearch').fetch 'host'
      require 'patron'
      # I use PATRON for transport API to have persistent connections
      # but that uses libcurl internally, which makes it not thread-safe
      ConnectionPool::Wrapper.new size: 3 do
        Elasticsearch::Client.new(host: host, request_timeout: 60)
      end
    end
  end

end
