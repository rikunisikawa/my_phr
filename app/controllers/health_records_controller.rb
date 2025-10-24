class HealthRecordsController < ApplicationController
  before_action :set_health_record, only: %i[show edit update destroy]
  before_action :set_custom_field_definitions, only: %i[new create edit update show]

  def index
    @health_records = current_user.health_logs.includes(:activity_logs).order(recorded_at: :desc)
  end

  def show; end

  def new
    @health_record = current_user.health_logs.build(recorded_at: Time.zone.now)
  end

  def edit; end

  def create
    @health_record = current_user.health_logs.build(health_record_params)

    if @health_record.save
      redirect_to health_records_path, notice: "健康ログを登録しました。"
    else
      flash.now[:alert] = "入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @health_record.update(health_record_params)
      redirect_to health_record_path(@health_record), notice: "健康ログを更新しました。"
    else
      flash.now[:alert] = "入力内容を確認してください。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_record.destroy
    redirect_to health_records_path, notice: "健康ログを削除しました。"
  end

  private

  def set_health_record
    @health_record = current_user.health_logs.includes(:activity_logs).find(params[:id])
  end

  def health_record_params
    permitted = params.require(:health_log).permit(
      :recorded_at,
      :mood,
      :stress_level,
      :fatigue_level,
      :notes,
      { custom_field_values: {} },
      activity_logs_attributes: {}
    )

    attributes = permitted.to_h
    attributes["custom_fields"] = build_custom_fields(@health_custom_fields, attributes.delete("custom_field_values"))

    activity_attributes = attributes.delete("activity_logs_attributes")
    if activity_attributes.present?
      processed_attributes = activity_attributes.each_with_object({}) do |(index, activity_attrs), result|
        attrs = activity_attrs.to_h.slice(
          "id",
          "activity_type",
          "duration_minutes",
          "intensity",
          "_destroy",
          "custom_field_values",
          "custom_fields_raw"
        )
        raw_json = attrs.delete("custom_fields_raw")
        raw_values = attrs.delete("custom_field_values")
        raw_values = parse_custom_fields_json(raw_json) if raw_values.blank? && raw_json.present?

        if attrs["activity_type"].blank?
          if attrs["id"].present?
            attrs["_destroy"] = true
            result[index] = attrs.symbolize_keys
          end
          next
        end

        attrs["custom_fields"] = build_custom_fields(@activity_custom_fields, raw_values)
        result[index] = attrs.symbolize_keys
      end

      attributes["activity_logs_attributes"] = processed_attributes if processed_attributes.present?
    end

    attributes.symbolize_keys
  end

  def build_custom_fields(definitions, raw_values)
    CustomFieldValueBuilder.new(definitions).build(raw_values)
  end

  def parse_custom_fields_json(raw_json)
    parsed = JSON.parse(raw_json)
    parsed.is_a?(Hash) ? parsed : {}
  rescue JSON::ParserError, TypeError
    {}
  end

  def set_custom_field_definitions
    fields = current_user.custom_fields
    @health_custom_fields = fields.for_category("health")
    @activity_custom_fields = fields.for_category("activity")
  end
end
