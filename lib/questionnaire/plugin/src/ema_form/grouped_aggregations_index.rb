class EmaForm
  class GroupedAggregationsIndex

    attr_reader :index

    def initialize fields, grouping
      @index = {}
      @fields = fields.map &:name
      @grouping = grouping
    end

    def add_mixed records
      get_group = method :group_aggregation
      grouped_records(records).each do |group_id, items|
        get_group.(group_id).add items
      end
    end

    def group_aggregation group_id
      index[group_id] ||= Aggregation.new(@fields)
    end

    def build_result
      result = index.to_a.each_with_object({}) do |item_pair, memo|
        group_id, group = item_pair
        memo[group_id] = group.aggregation
      end
      {
          indicators: result,
          schema: @grouping
      }
    end

    private

    def grouped_records records
      reducer = method :group_of_record
      records.reduce({}) do |hash, record|
        (hash[reducer.(record)] ||= []).push record
        hash
      end
    end

    def group_of_record record
      prov = 'school_province'.freeze
      mun = 'school_municipality'.freeze
      com = 'school_commune'.freeze

      data = record.data
      [prov, mun, com].map{ |attr| data[attr] }.join '.'.freeze
    end

    class Aggregation

      attr_reader :aggregation

      def initialize fields
        @aggregation = nil
        @fields = fields
      end

      def add records
        result = compute records

        if aggregation
          @fields.each do |name|
            aggregation[name] = (aggregation[name] + result[name]) / 2.0
          end

        else
          @aggregation = result

        end
      end

      private

      def compute records
        # memos for sums and counts
        sums = @fields.each_with_object({}) do |field, memo|
          memo[field] = 0
        end
        counts = sums.dup

        # fill in those memos
        records.each do |form|

          data = form.data
          @fields.each do |field|
            value = data[field]

            if value
              sums[field] += value
              counts[field] += 1
            end
          end

        end

        @fields.each_with_object({}) do |field, memo|
          count = counts[field]
          memo[field] = if count == 0
            0
          else
            (sums[field].to_f / count.to_f)
          end
        end

      end

    end

  end
end
