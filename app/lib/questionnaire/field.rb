Questionnaire

class Questionnaire::Field

  ATTRIBUTES = %w[name group type options].freeze

  OPT_OPTIONAL = 'optional'.freeze
  OPT_CONDITIONAL = 'conditional'.freeze

  attr_reader :name, :group, :type, :type_name

  def initialize name, group, type_name, type, options
    @name = name.freeze
    @group = group.freeze
    @type_name = type_name.to_sym
    @type = type

    apply_options parse_options(options)
  end

  def inspect
    "#<Questionnaire::Field name=#{name}, type=#{@type_name}>"
  end

  def self.try_parse row
    name, group, type_name, options = row
    unless [name, group, type_name].all?{|item| item.nil? || String === item }
      return [ nil, 'fields must contain strings (not numbers or other)']
    end

    type = TYPES[type_name.to_sym]
    unless type
      return [ nil, "unknown type #{type_name}" ]
    end

    field = new name, group, type_name, type, options
    [ field, nil ]
  end

  def valid_value? value
    if value.nil? && @can_be_nil
      true
    else
      type[:validate].(value)
    end
  end

  private

  OPT_REGEX = /^\s*(\w+)(?:=(.*))?\s*$/
  def parse_options options
    return {} if options.blank?

    options.split('&').each_with_object({}) do |opt, index|
      _, name, value = opt.match(OPT_REGEX)&.to_a
      index[name] = value || true if name
    end
  end

  def apply_options options
    @can_be_nil = options.key?(OPT_OPTIONAL) || options.key?(OPT_CONDITIONAL)
  end

  ########## DEFINED TYPES

  def self.put_type name, definition
    unless definition[:validate]
      raise "type #{name} doesn't define :validate function"
    end
    definition[:name] = name.to_sym
    definition[:to_csv] ||= TO_CSV_DEF
    TYPES[name] = definition.freeze
  end

  TO_CSV_DEF = (:itself).to_proc
  TYPES = {}

  put_type :string, {
      validate: -> (value) {
        String === value
      },
      to_csv: -> (value) {
        value && value.include?(',') ? "\"#{value}\"" : value
      }
  }

  put_type :integer, {
      validate: -> (value) {
        Integer === value
      }
  }

  put_type :number, {
      validate: -> (value) {
        Numeric === value
      }
  }

  put_type :timestamp, {
      validate: -> (value) {
        Numeric === value
      },
      to_csv: -> (value) {
        value && Time.at(value / 1000).to_s
      }
  }

  put_type :bool, {
      preprocess: -> (value) {
        value.nil? ? false : value
      },
      validate: -> (value) {
        value == true or value == false
      }
  }

  put_type :gps, {
      validate: -> (value) {
        Hash === value &&
            value.keys.sort == %w[n t] &&
            value.values.all?{|v| Numeric === v}
      },
      to_csv: -> (value) {
        "\"[#{value['n']},#{value['t']}]\"" if value
      },
      to_lon_lat: -> (value) {
        [value['n'], value['t']] if value
      }
  }

end
