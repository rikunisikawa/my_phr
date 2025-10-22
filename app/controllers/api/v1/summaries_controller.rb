module Api
  module V1
    class SummariesController < BaseController
      def show
        calculator = SummaryCalculator.new(
          user: current_user,
          period: params[:period] || "daily",
          start_date: params[:from],
          end_date: params[:to]
        )
        result = calculator.call

        render json: serialize_result(result)
      rescue ArgumentError => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      private

      def serialize_result(result)
        {
          period: result.period,
          range: result.range,
          buckets: result.buckets.map { |bucket| serialize_bucket(bucket) }
        }
      end

      def serialize_bucket(bucket)
        {
          label: bucket.label,
          from: bucket.from,
          to: bucket.to,
          averages: bucket.averages,
          total_activity_duration: bucket.total_activity_duration,
          activities_breakdown: bucket.activities_breakdown,
          custom_fields: bucket.custom_fields
        }
      end
    end
  end
end
