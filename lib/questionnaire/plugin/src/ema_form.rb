class EmaForm < Questionnaire

  include EmaForm::Elastic

  def self.fetch_data_table params, paginator
    pagination = paginator.(per_page_options: [10, 50])
    records = elastic.queries.filtered_records params
    records = records.paginate(*pagination).fetch_records

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

end

EmaForm.current_version_rank = 4
EmaForm::V4
