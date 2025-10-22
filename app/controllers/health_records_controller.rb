class HealthRecordsController < ApplicationController
  before_action :set_health_record, only: %i[show edit update destroy]

  def index
    @health_records = current_user.health_logs.includes(:activity_logs).order(recorded_at: :desc)
  end

  def show; end

  def new
    @health_record = current_user.health_logs.build(recorded_at: Time.zone.now)
    build_activity_slots
  end

  def edit; end

  def create
    attributes = health_record_params
    @health_record = current_user.health_logs.build(attributes)

    if @json_error.present?
      flash.now[:alert] = @json_error
      render :new, status: :unprocessable_entity
    elsif @health_record.save
      redirect_to health_records_path, notice: "健康ログを登録しました。"
    else
      flash.now[:alert] = "入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attributes = health_record_params

    if @json_error.present?
      assign_without_custom_fields(@health_record, attributes)
      flash.now[:alert] = @json_error
      render :edit, status: :unprocessable_entity
    elsif @health_record.update(attributes)
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
    @json_error = nil
    permitted = params.require(:health_log).permit(
      :recorded_at,
      :mood,
      :stress_level,
      :fatigue_level,
      :notes,
      :custom_fields_raw,
      activity_logs_attributes: %i[
        id
        activity_type
        duration_minutes
        intensity
        _destroy
        custom_fields_raw
      ]
    )

    attributes = permitted.to_h
    begin
      attributes[:custom_fields] = parse_custom_fields(attributes.delete("custom_fields_raw"))
      if attributes["activity_logs_attributes"].present?
        attributes["activity_logs_attributes"].transform_values! do |attrs|
          attrs = attrs.to_h
          raw_custom_fields = attrs.delete("custom_fields_raw")

          if attrs["activity_type"].blank?
            if attrs["id"].blank?
              next {}
            else
              attrs["_destroy"] = true
              next attrs.symbolize_keys
            end
          end

          attrs["custom_fields"] = parse_custom_fields(raw_custom_fields)
          attrs.symbolize_keys
        rescue JSON::ParserError => e
          @json_error = "カスタム項目のJSON形式が正しくありません: #{e.message}"
          attrs.symbolize_keys
        end
        attributes["activity_logs_attributes"].delete_if { |_key, attrs| attrs.blank? }
      end
    rescue JSON::ParserError => e
      @json_error = "カスタム項目のJSON形式が正しくありません: #{e.message}"
    end

    attributes.deep_symbolize_keys
  end

  def parse_custom_fields(raw_value)
    return {} if raw_value.blank?

    parsed = JSON.parse(raw_value)
    unless parsed.is_a?(Hash)
      raise JSON::ParserError, "JSONオブジェクトを入力してください"
    end
    parsed
  end

  def assign_without_custom_fields(record, attributes)
    sanitized = attributes.except(:custom_fields).dup
    if sanitized[:activity_logs_attributes]
      sanitized[:activity_logs_attributes] = sanitized[:activity_logs_attributes].transform_values do |activity_attrs|
        activity_attrs.except(:custom_fields)
      end
    end
    record.assign_attributes(sanitized)
  end
end
