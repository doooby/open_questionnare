module QuestionnaireVersions
  extend ActiveSupport::Concern

  class_methods do

    def current_version_rank= rank
      @current_version_rank = rank
    end

    def versions
      @versions ||= {}
    end

    def current_version
      @current_version ||= versions[@current_version_rank]
    end

  end

end
