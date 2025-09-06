class Api::V1::MonthSummariesController < Api::V1::BaseController
  def index
    @summaries = MonthSummary.all
    @summaries = @summaries.where(game_type: params[:game_type]) if params[:game_type].present?
    @summaries = @summaries.where(month: params[:month]) if params[:month].present?
    @summaries = @summaries.where(number: params[:number]) if params[:number].present?
    @summaries = @summaries.most_frequent.limit(params[:limit] || 100)
    
    render_success(@summaries)
  end

  def show
    @summary = MonthSummary.find(params[:id])
    render_success(@summary)
  rescue ActiveRecord::RecordNotFound
    render_error('Month summary not found', :not_found)
  end

  def by_month
    game_type = params[:game_type] || 'vietlot45'
    month = params[:month]
    limit = params[:limit] || 10
    
    if month.blank?
      render_error('Month is required', :bad_request)
      return
    end
    
    @summaries = MonthSummary.top_numbers_for_month(game_type, month.to_i, limit)
    render_success(@summaries)
  end

  def by_number
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    @summaries = MonthSummary.number_frequency_by_month(game_type, number.to_i)
    render_success(@summaries)
  end

  def seasonal_analysis
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    analysis = MonthSummary.seasonal_analysis(game_type, number.to_i)
    render_success(analysis)
  end

  def monthly_frequency
    game_type = params[:game_type] || 'vietlot45'
    
    analysis = {}
    (1..12).each do |month|
      analysis[month] = MonthSummary.top_numbers_for_month(game_type, month, 5)
    end
    
    render_success(analysis)
  end
end
