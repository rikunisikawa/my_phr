module Api
  module V1
    class CustomFieldsController < BaseController
      before_action :set_custom_field, only: %i[show update destroy]

      def index
        fields = current_user.custom_fields
        fields = fields.for_category(params[:category]) if params[:category].present?

        render json: fields.map { |field| serialize_field(field) }
      end

      def show
        render json: serialize_field(@custom_field)
      end

      def create
        custom_field = current_user.custom_fields.build(custom_field_params)

        if custom_field.save
          render json: serialize_field(custom_field), status: :created
        else
          render json: { errors: custom_field.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @custom_field.update(custom_field_params)
          render json: serialize_field(@custom_field)
        else
          render json: { errors: @custom_field.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @custom_field.destroy
        head :no_content
      end

      private

      def set_custom_field
        @custom_field = current_user.custom_fields.find(params[:id])
      end

      def custom_field_params
        params.require(:custom_field).permit(:name, :field_type, :category, options: [])
      end

      def serialize_field(field)
        field.as_json(only: %i[id name field_type category options])
      end
    end
  end
end
