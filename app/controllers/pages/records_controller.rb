module Pages
  class RecordsController < Pages::BaseController

    before_action :set_questionnaire

    attr_reader :questionnaire

    def fetch_data
      fetcher = "fetch_data_#{params[:fetch]}"
      if questionnaire.respond_to? fetcher
        paginator = -> (**opts) { pagination_params **opts }
        data = questionnaire.send fetcher, params, paginator
        render_ok data

      else
        render_fail 'no such fetcher'

      end
    end

    def download_csv
      records = fetch_records 1, 1000
      file = questionnaire.build_csv_tmpfile [records]

      time_stamp = Time.zone.now.strftime '%y-%m-%d_%H-%M'
      send_data file,
          type: 'text/csv; charset=utf-8;',
          filename: "oq_records_#{time_stamp}.csv"
    end

    private

    def set_questionnaire
      @questionnaire = Questionnaire.singleton_type
    end

    def fetch_records page, per_page
      q = questionnaire.elastic.queries.filtered_records params
      q.paginate(page, per_page).fetch_records
    end

  end
end
