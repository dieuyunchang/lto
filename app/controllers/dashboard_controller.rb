class DashboardController < ApplicationController
  def index
    @vietlot45_latest = LotteryDraw.latest_draw('vietlot45')
    @vietlot55_latest = LotteryDraw.latest_draw('vietlot55')
    @vietlot45_recent = LotteryDraw.vietlot45.recent.limit(5)
    @vietlot55_recent = LotteryDraw.vietlot55.recent.limit(5)
  end

  def vietlot45
    @game_type = 'vietlot45'
    @latest_draw = LotteryDraw.latest_draw('vietlot45')
    @recent_draws = LotteryDraw.vietlot45.recent.limit(20)
    @latest_predictions = Prediction.latest_predictions('vietlot45')
    @template_predictions = TemplatePrediction.latest_predictions('vietlot45')
  end

  def vietlot55
    @game_type = 'vietlot55'
    @latest_draw = LotteryDraw.latest_draw('vietlot55')
    @recent_draws = LotteryDraw.vietlot55.recent.limit(20)
    @latest_predictions = Prediction.latest_predictions('vietlot55')
    @template_predictions = TemplatePrediction.latest_predictions('vietlot55')
  end

  def statistics
    # Vietlot 45 statistics
    @vietlot45_stats = calculate_game_stats('vietlot45')
    @vietlot45_day_stats = calculate_day_of_week_stats('vietlot45')
    @vietlot45_month_stats = calculate_monthly_stats('vietlot45')
    @vietlot45_frequency_stats = calculate_frequency_stats('vietlot45')
    
    # Vietlot 55 statistics
    @vietlot55_stats = calculate_game_stats('vietlot55')
    @vietlot55_day_stats = calculate_day_of_week_stats('vietlot55')
    @vietlot55_month_stats = calculate_monthly_stats('vietlot55')
    @vietlot55_frequency_stats = calculate_frequency_stats('vietlot55')
  end

  def predictions
    # Get predictions for both games
    @vietlot45_predictions = Prediction.latest_predictions('vietlot45').order(score: :desc).limit(20)
    @vietlot55_predictions = Prediction.latest_predictions('vietlot55').order(score: :desc).limit(20)
    
    # Get template predictions for both games
    @vietlot45_templates = TemplatePrediction.latest_predictions('vietlot45').order(overall_probability: :desc).limit(10)
    @vietlot55_templates = TemplatePrediction.latest_predictions('vietlot55').order(overall_probability: :desc).limit(10)
  end
  
  private
  
  def calculate_game_stats(game_type)
    draws = LotteryDraw.where(game_type: game_type)
    latest_draw = draws.order(draw_date: :desc).first
    
    # Calculate most frequent numbers
    number_counts = {}
    draws.each do |draw|
      draw.numbers_array.each do |number|
        number_counts[number] = (number_counts[number] || 0) + 1
      end
    end
    
    top_numbers = number_counts.sort_by { |_, count| -count }.first(6).to_h
    
    {
      total_draws: draws.count,
      latest_draw_date: latest_draw&.draw_date&.strftime('%Y-%m-%d') || 'N/A',
      avg_prize: draws.average(:prize_amount)&.to_i || 0,
      top_numbers: top_numbers
    }
  end
  
  def calculate_day_of_week_stats(game_type)
    day_names = %w[sun mon tue wed thu fri sat]
    stats = Array.new(7, 0)
    
    DayOfWeekSummary.where(game_type: game_type).group(:day_of_week).sum(:count).each do |day, count|
      day_index = day_names.index(day)
      stats[day_index] = count if day_index
    end
    
    stats
  end
  
  def calculate_monthly_stats(game_type)
    stats = Array.new(12, 0)
    
    MonthSummary.where(game_type: game_type).group(:month).sum(:count).each do |month, count|
      stats[month - 1] = count if month >= 1 && month <= 12
    end
    
    stats
  end
  
  def calculate_frequency_stats(game_type)
    # Get top 20 most frequent numbers
    number_counts = {}
    LotteryDraw.where(game_type: game_type).each do |draw|
      draw.numbers_array.each do |number|
        number_counts[number] = (number_counts[number] || 0) + 1
      end
    end
    
    top_numbers = number_counts.sort_by { |_, count| -count }.first(20)
    
    {
      labels: top_numbers.map { |number, _| number.to_s },
      values: top_numbers.map { |_, count| count }
    }
  end

end
