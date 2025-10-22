class ProfilesController < ApplicationController
  before_action :set_profile

  def show; end

  def edit; end

  def update
    attributes = profile_params
    if @json_error.present?
      @profile.assign_attributes(attributes.except(:custom_fields))
      flash.now[:alert] = @json_error
      render :edit, status: :unprocessable_entity
    elsif @profile.update(attributes)
      redirect_to profile_path, notice: "基本情報を更新しました。"
    else
      flash.now[:alert] = "入力内容を確認してください。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
  end

  def profile_params
    permitted = params.require(:profile).permit(:age, :height_cm, :weight_kg, :custom_fields_json)
    attributes = permitted.to_h.symbolize_keys
    raw = attributes.delete(:custom_fields_json)
    @json_error = nil

    begin
      attributes[:custom_fields] = parse_custom_fields(raw)
    rescue JSON::ParserError => e
      @json_error = "カスタム項目のJSON形式が正しくありません: #{e.message}"
      @profile.errors.add(:custom_fields, @json_error)
      attributes[:custom_fields] = {}
    end
    attributes[:custom_fields] ||= {}
    attributes
  end

  def parse_custom_fields(raw_value)
    return {} if raw_value.blank?

    parsed = JSON.parse(raw_value)
    unless parsed.is_a?(Hash)
      raise JSON::ParserError, "JSONオブジェクトを入力してください"
    end
    parsed
  end
end
