namespace :records do

  desc 'deletes elastic index and imports all records'
  task elastic_reindex: :environment do
    questionnaire = Questionnaire.singleton_type
    es = questionnaire.elastic
    es.rebuild_index
    questionnaire.select_version.find_in_batches &(es.method :index_documents)
  end

end
