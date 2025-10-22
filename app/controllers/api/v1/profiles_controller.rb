module Api
  module V1
    class ProfilesController < BaseController
      before_action :set_profile, only: %i[show update]

      def show
        render json: serialize_profile(@profile)
      end

      def create
        profile = current_user.build_profile(profile_params)

        if profile.save
          render json: serialize_profile(profile), status: :created
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @profile.update(profile_params)
          render json: serialize_profile(@profile)
        else
          render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = current_user.profile || current_user.build_profile
      end

      def profile_params
        params.require(:profile).permit(:age, :height_cm, :weight_kg, custom_fields: {})
      end

      def serialize_profile(profile)
        profile.as_json(only: %i[id age height_cm weight_kg custom_fields])
      end
    end
  end
end
