module Pages
  class BaseController < ActionController::API

    include CommonActions

    before_action :authenticate
    before_action :change_locale

    private

    def change_locale
      locale = params[:locale].presence
      locale = Pages::LANGUAGES.first unless Pages::LANGUAGES.include? locale
      I18n.locale = locale
    end

    def pagination_params per_page_options: nil
      page = params[:page].presence&.to_i || 1

      per_page = params[:per_page].presence&.to_i
      if per_page_options
        per_page = per_page_options.first unless per_page_options.include? per_page
      end

      [page, per_page]
    end

  end
end
