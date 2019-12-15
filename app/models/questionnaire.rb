require 'csv'

class Questionnaire < ApplicationRecord

  include ElasticModel
  include QuestionnaireVersions

  belongs_to :user

  scope :select_version, -> (version=nil) {
    version ||= Questionnaire.singleton_type.current_version.rank
    where "data->>'version' = '#{version}'"
  }

  def self.singleton_type
    @singleton_type ||= OqWeb::QUESTIONNAIRE_SINGLETON_TYPE.constantize
  end

  def to_version
    version = data['version']
    version_klass = Questionnaire.singleton_type.versions[version] || (return nil)
    version_klass.new data
  end

  def stage_for_upgrade
    version = to_version || (return false)
    version = version.upgrade

    return false if version.attributes['version'] != Questionnaire.singleton_type.current_version.rank

    self.data = version.sanitized_attributes
    true
  end

  def self.import! list, user
    valid, invalid, unknown_version = Questionnaire.process_input_data list

    # valid upload items become Questionnaire
    valid.map! do |version|
      singleton_type.new(
          user: user,
          uploaded_at: Time.zone.now,
          data: version.sanitized_attributes
      )
    end

    # invalid upload items become InvalidUpload
    invalid.map! do |upload_item|
      InvalidUpload.new_from_params user, upload_item.attributes
    end

    # non-parsable data become InvalidUpload
    unknown_version.map! do |attrs|
      InvalidUpload.new_from_params user, attrs
    end

    list = [*valid, *invalid, *unknown_version]
    unless list.empty?
      Questionnaire.transaction{ list.each &:save! }

      index_only_version = singleton_type.current_version.rank
      valid.select!{|f| f.data['version'] == index_only_version}
      singleton_type.elastic.index_documents valid unless valid.empty?
    end
  end

  def self.process_input_data list
    versions = singleton_type.versions

    valid = []
    invalid = []
    unknown_version = []

    list.each do |attributes|
      version_klass = versions[attributes['version']]

      # if no such version class exists (version not known)
      unless version_klass
        unknown_version << attributes
        next
      end

      # try to parse the version data
      # on success push to valid
      # otherwise push to invalid
      upload_item = version_klass.new attributes
      upgraded_upload_item = (upload_item.upgrade if upload_item.valid?)
      if upgraded_upload_item
        valid.push upgraded_upload_item
      else
        invalid.push upload_item
      end
    end

    [valid, invalid, unknown_version]
  end

  def self.meta_fields
    @meta_fields ||= begin
      ::CSV.read(
          Rails.root.join 'lib/questionnaire/meta_fields.csv'
      ).each(&:freeze).freeze
    end
  end

  def build_csv_tmpfile records_batches, version_klass=current_version
    version_fields = version_klass.fields.values

    path = Rails.root.join "tmp/records_#{SecureRandom.uuid}.csv"
    csv = File.open path, 'w+'
    File.unlink path

    # headers
    csv.puts([
        'id',
        'uploaded_at',
        *version_fields.map(&:name)
    ].join ',')

    # data
    time_to_csv = Questionnaire::Field::TYPES[:timestamp][:to_csv]
    h = Questionnaire::FieldsHelpers
    records_batches.each do |batch|
      batch.each do |form|
        csv.puts([
            form.id,
            time_to_csv.(h.time_to_js form.uploaded_at),
            *version_fields.map(&(h.field_value_mapper form.data, :to_csv))
        ].join ',')
      end
    end

    csv.rewind
    csv
  end

end
