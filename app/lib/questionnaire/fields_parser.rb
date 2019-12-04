Questionnaire
require 'csv'

class Questionnaire::FieldsParser

  def self.call questionnaire_name, rank, file
    unless File.exists? file
      raise "#{questionnaire_name}:#{rank} - fields.csv not found"
    end

    fields = ::CSV.read file
    attributes = fields.shift
    unless attributes == Questionnaire::Field::ATTRIBUTES
      raise '%s:%s - missing or out-of-order attributes (expected: %s)' % [
          questionnaire_name,
          rank.to_s,
          Questionnaire::Field::ATTRIBUTES.join(',')
      ]
    end

    parser = new fields
    [ parser.process, parser ]
  end

  attr_reader :fields, :duplicated_fields, :invalid_fields

  def initialize fields_rows
    @fields_rows = [
        *Questionnaire.meta_fields,
        *fields_rows
    ]
    @duplicated_fields = []
    @invalid_fields = []
  end

  def process
    # check duplications
    names_memo = []
    @fields_rows.each do |field|
      name = field.to_s
      if names_memo.include? name
        duplicated_fields.push name
      else
        names_memo.push name
      end
    end
    return false unless duplicated_fields.empty?

    # check validity of each field
    @fields = @fields_rows.map do |row|
      field, error = Questionnaire::Field.try_parse row
      invalid_fields.push [ row.first, error ] unless field
      field
    end
    return false unless invalid_fields.empty?

    true
  end

end
