class InvalidUpload < ApplicationRecord

  def parsed_data
    @parsed_data ||= JSON.parse(data)
  end

  def self.new_from_params user, params
    new(
        user_id: user.id,
        data: JSON.generate(params),
        uploaded_at: Time.zone.now
    )
  end

  def self.try_reprocess!
    count = InvalidUpload.count

    InvalidUpload.all.each do |record|
      upload_item = record.reprocess[:valid]
      if upload_item

        questionnaire = Questionnaire.singletion.new(
            user: User.find(record.user_id),
            uploaded_at: record.uploaded_at,
            data: upload_item.sanitized_attributes
        )

        if questionnaire.save
          record.destroy!
          questionnaire.elastic_index!
        end
        
      end
    end

    count_left = InvalidUpload.count
    {
        processed: count - count_left,
        left: count_left
    }
  end

  def reprocess
    valid, invalid, _unknown_version = Questionnaire.process_input_data [parsed_data]
    {
        valid: valid.first,
        invalid: invalid.first
    }
  end

  def list_invalid_fields
    upload_item = reprocess[:invalid] || return
    upload_item.invalid_fields.map do |field|
      { field: field, value: parsed_data[field.name] }
    end
  end

end
