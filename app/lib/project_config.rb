module ProjectConfig
  extend ActiveSupport::Concern

  class_methods do

    def project_label
      @project_label ||= self.name.demodulize.underscore.dasherize.freeze
    end

    def questionnaires
      @questionnaires ||= {}
    end

    def questionnaire label, &block
      label = label.to_s
      q = QuestionnaireDefinition.new project_label, label
      q.define_and_load block
      q.freeze
      questionnaires[label] = q
    end

    def active_questionnaires
      questionnaires.select{|_, q| q.active? }
    end

  end

  class QuestionnaireDefinition

    attr_reader :project_label, :label, :meta

    def initialize project_label, label
      @project_label = project_label
      @label = label.freeze
      @active = false
      @meta = {}
    end

    def freeze
      meta.freeze
      super
    end

    def active?
      @active.eql? true
    end

    def define_and_load block
      api = Api.new
      api.instance_exec &block if block

      meta_config = Questionnaire.find_config label, 'meta'
      unless parse_metadata meta_config&.parse_csv_config
        raise_error! 'failed to parse metadata'
      end

      version = meta[:current_version]
      unless Questionnaire.config_exists? label, 'fields', version
        raise_error! "missing fields for current version #{version}"
      end

      @active = true

    rescue QuestionnaireError => e
      Rails.logger.warn "QuestionnaireError: #{e.message}"

    end

    def parse_metadata data
      meta[:current_version] = data.get_row('current_version') || (return false)

      true

    rescue => e
      Rails.logger.warn "QuestionnaireError: failed on unknown exception"
      Rails.logger.warn e.message
      false

    end

    def code_dir
      Rails.root.join 'lib/projects', project_label, label
    end

    private

    def raise_error! message
      raise QuestionnaireError.new(self, message)
    end

    class Api

      attr_reader :configs

      def initialize
        @custom_configs = []
      end

      def has_config label
        @custom_configs.push label
      end

    end

  end

  class QuestionnaireError < StandardError

    attr_reader :questionnaire

    def initialize questionnaire, message
      @questionnaire = questionnaire
      super '[%s::%s] %s' % [
          questionnaire.project_label,
          questionnaire.label,
          message
      ]
    end

  end

end
