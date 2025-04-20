class HealthRecordsController < ApplicationController
  def index
    @health_records = HealthRecord.all
  end

  def new
    @health_record = HealthRecord.new
    @custom_field_definitions = CustomFieldDefinition.where(user_id: current_user&.id) # ユーザーIDに基づいてフィルタリング
  end

  def create
    @health_record = HealthRecord.new(health_record_params)
    @health_record.profile = current_user.profile if current_user&.profile

    if @health_record.save
      p @health_record.date
      redirect_to health_records_path, notice: '健康記録が作成されました。'
    else
      @custom_field_definitions = CustomFieldDefinition.where(user_id: current_user&.id)
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    @health_record = HealthRecord.find(params[:id])
    @custom_field_definitions = CustomFieldDefinition.where(user_id: current_user&.id) # ユーザーIDに基づいてフィルタリング
  end

  def update
  end

  def destroy
  end
  private

  def health_record_params
    params.require(:health_record).permit(:date, :mood, :stress, :fatigue, :sleep_duration, :sleep_quality, :memo, custom_fields: {})
  end

  def summary
    @health_records = HealthRecord.all
    render 'summary'
  end
end
