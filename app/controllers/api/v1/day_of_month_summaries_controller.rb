class Api::V1::DayOfMonthSummariesController < Api::V1::BaseController
  def index
    @summaries = DayOfMonthSummary.all
    @summaries = @summaries.where(game_type: params[:game_type]) if params[:game_type].present?
    @summaries = @summaries.where(day_of_month: params[:day_of_month]) if params[:day_of_month].present?
    @summaries = @summaries.where(number: params[:number]) if params[:number].present?
    @summaries = @summaries.most_frequent.limit(params[:limit] || 100)
    
    render_success(@summaries)
  end

  def show
    @summary = DayOfMonthSummary.find(params[:id])
    render_success(@summary)
  rescue ActiveRecord::RecordNotFound
    render_error('Day of month summary not found', :not_found)
  end

  def by_day_of_month
    game_type = params[:game_type] || 'vietlot45'
    day_of_month = params[:day_of_month]
    limit = params[:limit] || 10
    
    if day_of_month.blank?
      render_error('Day of month is required', :bad_request)
      return
    end
    
    @summaries = DayOfMonthSummary.top_numbers_for_day_of_month(game_type, day_of_month.to_i, limit)
    render_success(@summaries)
  end

  def by_number
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    @summaries = DayOfMonthSummary.number_frequency_by_day_of_month(game_type, number.to_i)
    render_success(@summaries)
  end

  def week_analysis
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    analysis = DayOfMonthSummary.week_analysis(game_type, number.to_i)
    render_success(analysis)
  end

  def weekly_frequency
    game_type = params[:game_type] || 'vietlot45'
    
    analysis = {}
    (1..31).each do |day|
      analysis[day] = DayOfMonthSummary.top_numbers_for_day_of_month(game_type, day, 3)
    end
    
    render_success(analysis)
  end
end
