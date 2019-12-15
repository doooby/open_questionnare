class EmaForm < Questionnaire

  include EmaForm::Elastic

  def self.fetch_data_table params, paginator
    pagination = paginator.(per_page_options: [10, 50])
    query = elastic.queries.filtered_records params
    records = query.paginate(*pagination).fetch_records

    h = Questionnaire::FieldsHelpers
    items = records.map do |r|
      r.data.merge(
          'qid' => r.id,
          'uploaded_at' => h.time_to_js(r.uploaded_at)
      )
    end
    {
        items: items,
        total: records.total_count
    }
  end

  def self.fetch_data_overview params, _
    query = elastic.queries.filtered_records params
    query.paginate 1, 1000

    index = current_version.new_indicators_aggregation

    loop do
      records = query.fetch_records
      index.add_mixed records

      break unless records.more?
      query.next_page!
    end

    {
        data: index.build_result
    }
  end

end

EmaForm.current_version_rank = 4
EmaForm::V4
