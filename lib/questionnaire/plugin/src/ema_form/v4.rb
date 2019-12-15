class EmaForm
  class V4 < EmaForm::VersionBaseType

    define_version_type EmaForm, self, __dir__

    INDICATORS = fields.values.select{|f| f.options.key? 'ema'}.freeze
    INDICATORS_GROUPING = INDICATORS.each_with_object({}) do |field, memo|
      (memo[field.group] ||= []).push field.name
    end

    def self.new_indicators_aggregation
      EmaForm::GroupedAggregationsIndex.new INDICATORS, INDICATORS_GROUPING
    end

  end
end
