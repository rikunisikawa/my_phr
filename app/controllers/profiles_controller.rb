class ProfilesController < ApplicationController
  before_action :set_profile

  def show; end

  def edit; end

  def update
    attributes = profile_params
    if @profile.update(attributes)
      redirect_to profile_path, notice: "基本情報を更新しました。"
    else
      flash.now[:alert] = "入力内容を確認してください。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
    @profile_custom_fields = current_user.custom_fields.for_category("profile")
  end

  def profile_params
    permitted = params.require(:profile).permit(:age, :height_cm, :weight_kg, custom_field_values: {})
    attributes = permitted.to_h.symbolize_keys
    raw_values = attributes.delete(:custom_field_values) || {}
    builder = CustomFieldValueBuilder.new(@profile_custom_fields)
    attributes[:custom_fields] = builder.build(raw_values)
    attributes
  end
end
