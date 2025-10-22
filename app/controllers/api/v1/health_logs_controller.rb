module Api
  module V1
    class HealthLogsController < BaseController
      before_action :set_health_log, only: %i[show update destroy]

      def index
        logs = current_user.health_logs.between(params[:from], params[:to]).order(recorded_at: :desc)
        render json: logs.map { |log| serialize_health_log(log) }
      end

      def show
        render json: serialize_health_log(@health_log)
      end

      def create
        health_log = current_user.health_logs.build(health_log_params)

        if health_log.save
          render json: serialize_health_log(health_log), status: :created
        else
          render json: { errors: health_log.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @health_log.update(health_log_params)
          render json: serialize_health_log(@health_log)
        else
          render json: { errors: @health_log.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @health_log.destroy
        head :no_content
      end

      private

      def set_health_log
        @health_log = current_user.health_logs.find(params[:id])
      end

      def health_log_params
        params.require(:health_log).permit(
          :recorded_at,
          :mood,
          :stress_level,
          :fatigue_level,
          :notes,
          { custom_fields: {} },
          activity_logs_attributes: [
            :id,
            :activity_type,
            :duration_minutes,
            :intensity,
            :_destroy,
            { custom_fields: {} }
          ]
        )
      end

      def serialize_health_log(log)
        log.as_json(
          only: %i[id recorded_at mood stress_level fatigue_level notes custom_fields],
          include: {
            activity_logs: {
              only: %i[id activity_type duration_minutes intensity custom_fields]
            }
          }
        )
      end
    end
  end
end
