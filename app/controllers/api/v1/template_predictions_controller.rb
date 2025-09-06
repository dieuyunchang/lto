class Api::V1::TemplatePredictionsController < Api::V1::BaseController
  def index
    @template_predictions = TemplatePrediction.all
    @template_predictions = @template_predictions.where(game_type: params[:game_type]) if params[:game_type].present?
    @template_predictions = @template_predictions.where('overall_probability >= ?', params[:min_probability]) if params[:min_probability].present?
    @template_predictions = @template_predictions.where('confidence_level >= ?', params[:min_confidence]) if params[:min_confidence].present?
    @template_predictions = @template_predictions.latest.limit(params[:limit] || 100)
    
    render_success(@template_predictions)
  end

  def show
    @template_prediction = TemplatePrediction.find(params[:id])
    render_success(@template_prediction)
  rescue ActiveRecord::RecordNotFound
    render_error('Template prediction not found', :not_found)
  end

  def top_predictions
    game_type = params[:game_type] || 'vietlot45'
    limit = params[:limit] || 10
    @template_predictions = TemplatePrediction.top_predictions(game_type, limit)
    render_success(@template_predictions)
  end

  def by_template
    game_type = params[:game_type] || 'vietlot45'
    template_id = params[:template_id]
    
    if template_id.blank?
      render_error('Template ID is required', :bad_request)
      return
    end
    
    @template_predictions = TemplatePrediction.by_template(game_type, template_id)
    render_success(@template_predictions)
  end

  def high_probability
    game_type = params[:game_type] || 'vietlot45'
    @template_predictions = TemplatePrediction.where(game_type: game_type).high_probability.latest
    render_success(@template_predictions)
  end

  def overdue_templates
    game_type = params[:game_type] || 'vietlot45'
    @template_predictions = TemplatePrediction.where(game_type: game_type)
                                             .select { |tp| tp.overdue? }
    render_success(@template_predictions)
  end
end
