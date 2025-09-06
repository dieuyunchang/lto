class Api::V1::PredictionsController < Api::V1::BaseController
  before_action :set_game_type, only: [:vietlot45, :vietlot55]

  def index
    @predictions = Prediction.all
    @predictions = @predictions.where(game_type: params[:game_type]) if params[:game_type].present?
    @predictions = @predictions.where(confidence: params[:confidence]) if params[:confidence].present?
    @predictions = @predictions.where(trend: params[:trend]) if params[:trend].present?
    @predictions = @predictions.latest.limit(params[:limit] || 100)
    
    render_success(@predictions)
  end

  def show
    @prediction = Prediction.find(params[:id])
    render_success(@prediction)
  rescue ActiveRecord::RecordNotFound
    render_error('Prediction not found', :not_found)
  end

  def vietlot45
    @predictions = Prediction.vietlot45.latest.limit(params[:limit] || 100)
    render_success(@predictions)
  end

  def vietlot55
    @predictions = Prediction.vietlot55.latest.limit(params[:limit] || 100)
    render_success(@predictions)
  end

  def top_predictions
    game_type = params[:game_type] || 'vietlot45'
    limit = params[:limit] || 10
    @predictions = Prediction.top_predictions(game_type, limit)
    render_success(@predictions)
  end

  def by_confidence
    game_type = params[:game_type] || 'vietlot45'
    confidence = params[:confidence] || 'high'
    @predictions = Prediction.by_confidence_level(game_type, confidence)
    render_success(@predictions)
  end

  private

  def set_game_type
    @game_type = action_name == 'vietlot45' ? 'vietlot45' : 'vietlot55'
  end
end
