class CustomFieldsController < ApplicationController
  before_action :load_custom_fields, only: %i[index create]
  before_action :set_custom_field, only: :destroy

  def index
    @options_text_values ||= {}
  end

  def create
    @custom_field = current_user.custom_fields.build(custom_field_params)
    form_category = params.dig(:custom_field, :category).presence || @custom_field.category
    form_category = form_category.to_s
    category_key = CustomField::CATEGORIES.include?(form_category) ? form_category : CustomField::CATEGORIES.first

    if @custom_field.save
      redirect_to custom_fields_path(anchor: @custom_field.category), notice: "カスタム項目を追加しました。"
    else
      @form_objects[category_key] = @custom_field
      @options_text_values[category_key] = params.dig(:custom_field, :options_text)
      flash.now[:alert] = "入力内容を確認してください。"
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    category = @custom_field.category
    @custom_field.destroy
    redirect_to custom_fields_path(anchor: category), notice: "カスタム項目を削除しました。"
  end

  private

  def load_custom_fields
    fields = current_user.custom_fields.order(:category, :created_at)
    @grouped_fields = fields.group_by(&:category)
    @form_objects = CustomField::CATEGORIES.index_with do |category|
      CustomField.new(category: category, field_type: "text")
    end
    @options_text_values = {}
  end

  def set_custom_field
    @custom_field = current_user.custom_fields.find(params[:id])
  end

  def custom_field_params
    permitted = params.require(:custom_field).permit(:name, :field_type, :category, :options_text)
    options = parse_options(permitted.delete(:options_text))
    permitted[:options] = permitted[:field_type] == "select" ? options : nil
    permitted
  end

  def parse_options(text)
    return nil if text.blank?

    text.split(/\r?\n/).map(&:strip).reject(&:blank?)
  end
end
