module Pages
  class RecordsController < Pages::BaseController

    before_action :set_prescript

    attr_reader :prescript

    # def browse_fetch
    #   forms = fetch_forms *pagination_params(per_page_options: [10, 50])
    #   items = prescript.data_processors.run :table_data, forms, prescript.current_version
    #   render_ok items: items, total: forms.total_count
    # end

    # def aggregations_fetch
    #   result = prescript.data_processors.run 'all_indicators',
    #       query: prescript.elastic.queries.filtered_records(params),
    #       pagination: pagination_params,
    #       version: prescript.current_version
    #   render_ok data: result
    # end

    # def map_tab_search
    #   forms = fetch_forms 1, 100
    #   items = prescript.data_processors.run :map_data, forms, prescript.current_version
    #   render_ok items: items
    # end

    # def download_csv
    #   forms = fetch_forms 1, 1000
    #   file = prescript.build_csv_tmpfile [forms]
    #
    #   time_stamp = Time.zone.now.strftime '%y-%m-%d_%H-%M'
    #   send_data file,
    #       type: 'text/csv; charset=utf-8;',
    #       filename: "ema_records_#{time_stamp}.csv"
    # end

    # def stats_tab_search
    #   forms = fetch_forms 1, 1000
    #   result = prescript.data_processors.run :indicators, forms, prescript.current_version
    #   render_ok data: result
    # end

    private

    def set_prescript
      @prescript = Form.prescript
    end

    def fetch_forms page, per_page
      q = prescript.elastic.queries.filtered_records params
      q.paginate(page, per_page).fetch_records
    end

  end
end
