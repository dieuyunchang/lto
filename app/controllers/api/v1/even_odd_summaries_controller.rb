class Api::V1::EvenOddSummariesController < Api::V1::BaseController
  def index
    @summaries = EvenOddSummary.all
    @summaries = @summaries.where(game_type: params[:game_type]) if params[:game_type].present?
    @summaries = @summaries.where(even_odd_type: params[:even_odd_type]) if params[:even_odd_type].present?
    @summaries = @summaries.where(number: params[:number]) if params[:number].present?
    @summaries = @summaries.most_frequent.limit(params[:limit] || 100)
    
    render_success(@summaries)
  end

  def show
    @summary = EvenOddSummary.find(params[:id])
    render_success(@summary)
  rescue ActiveRecord::RecordNotFound
    render_error('Even/odd summary not found', :not_found)
  end

  def by_even_odd_type
    game_type = params[:game_type] || 'vietlot45'
    even_odd_type = params[:even_odd_type]
    limit = params[:limit] || 10
    
    if even_odd_type.blank?
      render_error('Even/odd type is required', :bad_request)
      return
    end
    
    @summaries = EvenOddSummary.top_numbers_for_even_odd(game_type, even_odd_type, limit)
    render_success(@summaries)
  end

  def by_number
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    @summaries = EvenOddSummary.number_frequency_by_even_odd(game_type, number.to_i)
    render_success(@summaries)
  end

  def even_odd_comparison
    game_type = params[:game_type] || 'vietlot45'
    number = params[:number]
    
    if number.blank?
      render_error('Number is required', :bad_request)
      return
    end
    
    comparison = EvenOddSummary.even_odd_comparison(game_type, number.to_i)
    render_success(comparison)
  end

  def bias_analysis
    game_type = params[:game_type] || 'vietlot45'
    
    bias_results = EvenOddSummary.bias_analysis(game_type)
    render_success(bias_results)
  end

  def even_odd_frequency
    game_type = params[:game_type] || 'vietlot45'
    
    analysis = {
      even: EvenOddSummary.top_numbers_for_even_odd(game_type, 'even', 20),
      odd: EvenOddSummary.top_numbers_for_even_odd(game_type, 'odd', 20)
    }
    
    render_success(analysis)
  end
end
