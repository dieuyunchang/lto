class Api::V1::DayOfWeekSummariesController < Api::V1::BaseController
  def index
    @summaries = DayOfWeekSummary.all
    @summaries = @summaries.where(game_type: params[:game_type]) if params[:game_type].present?
    @summaries = @summaries.where(day_of_week: params[:day_of_week]) if params[:day_of_week].present?
    @summaries = @summaries.where(number: params[:number]) if params[:number].present?
    @summaries = @summaries.most_frequent.limit(params[:limit] || 100)
    
    render_success(@summaries)
  end

  def show
    @summary = DayOfWeekSummary.find(params[:id])
    render_success(@summary)
  rescue ActiveRecord::RecordNotFound
    render_error('Day of week summary not found', :not_found)
  end

  def by_day
    game_type = params[:game_type] || 'vietlot45'
    day_of_week = params[:day_of_week]
    limit = params[:limit] || 10
    
    if day_of_week.blank?
      render_error('Day of week is required', :bad_request)
      return
    end
    
    @summaries = DayOfWeekSummary.top_numbers_for_day(game_type, day_of_week, limit)
    render_success(@summaries)
  end

  def by_number
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    @summaries = DayOfWeekSummary.number_frequency_by_day(game_type, number.to_i)
    render_success(@summaries)
  end

  def frequency_analysis
    game_type = params[:game_type] || 'vietlot45'
    
    analysis = {}
    DayOfWeekSummary.day_names.keys.each do |day|
      analysis[day] = DayOfWeekSummary.top_numbers_for_day(game_type, day, 5)
    end
    
    render_success(analysis)
  end
end
