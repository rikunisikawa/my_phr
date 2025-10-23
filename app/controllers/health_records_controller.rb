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
      activity_logs_attributes: [
        :id,
        :activity_type,
        :duration_minutes,
        :intensity,
        :_destroy,
        { custom_field_values: {} }
      ]
    )

    attributes = permitted.to_h
    attributes["custom_fields"] = build_custom_fields(@health_custom_fields, attributes.delete("custom_field_values"))

    if attributes["activity_logs_attributes"].present?
      attributes["activity_logs_attributes"].transform_values! do |activity_attrs|
        attrs = activity_attrs.to_h
        raw_values = attrs.delete("custom_field_values")

        if attrs["activity_type"].blank?
          if attrs["id"].present?
            attrs["_destroy"] = true
            next attrs.symbolize_keys
          else
            next {}
          end
        end

        attrs["custom_fields"] = build_custom_fields(@activity_custom_fields, raw_values)
        attrs.symbolize_keys
      end
      attributes["activity_logs_attributes"].delete_if { |_key, attrs| attrs.blank? }
    end

    attributes.deep_symbolize_keys
  end

  def build_custom_fields(definitions, raw_values)
    CustomFieldValueBuilder.new(definitions).build(raw_values)
  end

  def set_custom_field_definitions
    fields = current_user.custom_fields
    @health_custom_fields = fields.for_category("health")
    @activity_custom_fields = fields.for_category("activity")
  end
end
