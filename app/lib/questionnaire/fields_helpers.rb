Questionnaire

module Questionnaire::FieldsHelpers

  extend self

  def parse_timestamp value
    Time.at value / 1000
  end

  def time_to_js time
    time.to_i * 1000
  end

  def field_value_mapper data, mapper
    -> (field) { field.type.send(mapper).(data[field.name]) }
  end

end
