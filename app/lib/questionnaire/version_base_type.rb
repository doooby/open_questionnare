# this class deals with parsing uploaded data
# and produces either valid Questionnaire `#sanitized_attributes` or
# errors in form of `#invalid_field`
class Questionnaire
  class VersionBaseType

    attr_reader :attributes

    def initialize data
      @attributes = data.with_indifferent_access

      self.class.fields.values.
          select{|f| f.type[:preprocess]}.
          each do |field|
        attributes[field.name] = field.type[:preprocess].(attributes[field.name])
      end
    end

    def valid?
      self.class.fields.values.all? &(method :valid_field?)
    end

    def valid_field? field
      field.valid_value? attributes[field.name]
    end

    def invalid_fields
      self.class.fields.values.reject &(method :valid_field?)
    end

    def sanitized_attributes
      fields = self.class.fields.values

      attrs = attributes.to_hash.slice *(fields.map &:name)

      fields.select{|f| f.type[:sanitize]}.each do |field|
        attrs[field.name] = field.type[:sanitize].(attrs[field.name])
      end

      attrs.reject{|_, value| value.nil?}
    end

    def upgrade
      self
    end

    class << self

      attr_reader :rank, :fields

      def define_version_type questionnaire, version, files_path
        _, rank = version.name.demodulize.match(/^V(\d+)$/)&.to_a
        raise 'version klass name must be `V<number>`' unless rank

        @rank = rank.to_i
        @fields = parse_version_fields!(rank, files_path).
            each_with_object({}){ |field, index| index[field.name] = field }
        @fields.freeze

        questionnaire.versions[@rank] = self
      end

      def parse_version_fields! rank, path
        success, parser = Questionnaire::FieldsParser.(
            'questionnaire', rank, File.expand_path("v#{rank}_fields.csv", path)
        )
        return parser.fields.compact if success

        unless parser.duplicated_fields.empty?
          raise [
              'there are some duplicate fields:',
              parser.duplicated_fields.join(',')
          ].join("\n")
        end

        unless parser.invalid_fields.empty?
          raise [
              'some fields failed to parse:',
              *parser.invalid_fields.map{|name, err| "#{name} - #{err}" }
          ].join("\n")
        end

        raise 'undefined parse issue'

      end
    end

  end
end
