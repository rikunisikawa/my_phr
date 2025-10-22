module Api
  module V1
    class ActivityLogsController < BaseController
      before_action :set_health_log
      before_action :set_activity_log, only: %i[update destroy]

      def create
        activity_log = @health_log.activity_logs.build(activity_log_params)

        if activity_log.save
          render json: serialize_activity_log(activity_log), status: :created
        else
          render json: { errors: activity_log.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @activity_log.update(activity_log_params)
          render json: serialize_activity_log(@activity_log)
        else
          render json: { errors: @activity_log.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @activity_log.destroy
        head :no_content
      end

      private

      def set_health_log
        @health_log = current_user.health_logs.find(params[:health_log_id])
      end

      def set_activity_log
        @activity_log = @health_log.activity_logs.find(params[:id])
      end

      def activity_log_params
        params.require(:activity_log).permit(:activity_type, :duration_minutes, :intensity, custom_fields: {})
      end

      def serialize_activity_log(activity_log)
        activity_log.as_json(only: %i[id activity_type duration_minutes intensity custom_fields])
      end
    end
  end
end
