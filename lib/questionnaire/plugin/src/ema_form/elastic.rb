class EmaForm
  module Elastic
    extend ActiveSupport::Concern

    def to_elastic_document
      {
          province: data['school_province'],
          municipality: data['school_municipality'],
          commune: data['school_commune'],

          user: data['user'],
          uploaded: uploaded_at.to_date,
          finalized: Questionnaire::FieldsHelpers.parse_timestamp(
              data['finalized_at']
          ).to_date,
          discipline: data['class_discipline'],
          school: data['school_name'],
          teacher: data['teacher_name'],
      }
    end

    included do

      es_prop_ema_text = {
          type: 'text',
          analyzer: 'ema_text',
          search_analyzer: 'ema_text'
      }

      elastic.define_index(
          settings: {
              index: {
                  number_of_shards: 1,
                  number_of_replicas: 0
              },

              analysis: {
                  filter: {
                      ema_ngram_filter: {
                          type: 'ngram',
                          min_gram: 3,
                          max_gram: 3
                      }
                  },
                  analyzer: {
                      ema_text: {
                          type: 'custom',
                          tokenizer: 'standard',
                          filter: %w[ema_ngram_filter]
                      }
                  }
              }
          },

          mappings: {
              properties: {
                  province: { type: 'keyword' },
                  municipality: { type: 'keyword' },
                  commune: { type: 'keyword' },

                  user: { type: 'keyword' },
                  uploaded: { type: 'date' },
                  finalized: { type: 'date' },

                  discipline: { type: 'keyword' },
                  school: es_prop_ema_text,
                  teacher: es_prop_ema_text,
                  supervisor: es_prop_ema_text,
              }
          }
      )

      elastic.define_queries do

        def self.filtered_records params
          query = new_query.track_scores

          param = -> (param_name, &block) {
            value = params[param_name].presence
            block.(value) if value
          }

          param.(:finalized){|value|
            query.add_filter range: {finalized: {
                gte: value[:from],
                lte: value[:to],
            }}
          }

          param.(:uploaded){|value|
            query.add_filter range: {uploaded: {
                gte: value[:from],
                lte: value[:to],
            }}
          }

          param.(:collector){|value|
            users = User.where(id: value).pluck :login
            query.add_filter terms: {user: users}
          }

          param.(:discipline){|value| query.add_filter terms: {discipline: value}}

          param.(:school){|value| query.add_must match: {school: value}}

          param.(:teacher){|value| query.add_must match: {teacher: value}}

          param.(:location){|value|
            province = value[:province].presence
            if province
              query.add_filter term: {province: province}

              municipality = value[:municipality].presence
              if municipality
                query.add_filter term: {municipality: municipality}

                commune = value[:commune].presence
                query.add_filter term: {commune: commune} if commune
              end
            end
          }

          query
        end

      end # define_queries

    end

  end
end
