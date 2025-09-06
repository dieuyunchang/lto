class DataUpdateJob < ApplicationJob
  queue_as :default

  def perform(game_type = nil)
    if game_type
      update_game_data(game_type)
    else
      update_game_data('vietlot45')
      update_game_data('vietlot55')
    end
  end

  private

  def update_game_data(game_type)
    Rails.logger.info "Starting data update for #{game_type}"
    
    # Update lottery draws
    update_lottery_draws(game_type)
    
    # Update predictions
    update_predictions(game_type)
    
    # Update template predictions
    update_template_predictions(game_type)
    
    # Update statistical summaries
    update_statistical_summaries(game_type)
    
    Rails.logger.info "Completed data update for #{game_type}"
  end

  def update_lottery_draws(game_type)
    json_file = Rails.root.join("../../vloto/#{game_type}/json-data/#{game_type}-data.json")
    return unless File.exist?(json_file)
    
    data = JSON.parse(File.read(json_file))
    
    data.each do |draw_data|
      date_str = draw_data['date']
      draw_date = parse_vietnamese_date(date_str)
      
      LotteryDraw.find_or_create_by(
        game_type: game_type,
        draw_date: draw_date
      ) do |draw|
        draw.date_string = draw_data['date']
        draw.numbers = draw_data['numbers']
        draw.prize_amount = draw_data['prize'].to_i
        draw.prize_string = draw_data['prize_s']
        draw.total = draw_data['total']
        draw.total_even_or_odd = draw_data['total_even_or_odd']
        draw.odd_count = draw_data['odd_count']
        draw.even_count = draw_data['even_count']
        draw.template_id = draw_data['template_id']
        draw.template_appear_comback_from_prev_count = draw_data['template_appear_comback_from_prev_count']
        draw.template_continuos_count = draw_data['template_continuos_count']
        draw.template_appear_count = draw_data['template_appear_count']
      end
    end
  end

  def update_predictions(game_type)
    predictions_file = Rails.root.join("../../vloto/#{game_type}/json-data/predictions.json")
    return unless File.exist?(predictions_file)
    
    data = JSON.parse(File.read(predictions_file))
    prediction_date = Time.current
    
    # Clear old predictions for this game type
    Prediction.where(game_type: game_type).delete_all
    
    data['predictedNumbers'].each do |pred_data|
      Prediction.create!(
        game_type: game_type,
        number: pred_data['number'],
        score: pred_data['score'],
        trend: pred_data['trend'],
        strength: pred_data['strength'],
        confidence: pred_data['confidence'],
        forecast: pred_data['forecast'],
        prediction_date: prediction_date
      )
    end
  end

  def update_template_predictions(game_type)
    template_file = Rails.root.join("../../vloto/#{game_type}/json-data/template-predictions.json")
    return unless File.exist?(template_file)
    
    data = JSON.parse(File.read(template_file))
    prediction_date = Time.current
    
    # Clear old template predictions for this game type
    TemplatePrediction.where(game_type: game_type).delete_all
    
    data['top_predictions'].each do |template_data|
      TemplatePrediction.create!(
        game_type: game_type,
        template_id: template_data['template_id'],
        total_appearances: template_data['total_appearances'],
        days_since_last: template_data['days_since_last'],
        current_continuous_count: template_data['current_continuous_count'],
        average_comeback_interval: template_data['average_comeback_interval'],
        max_continuous_count: template_data['max_continuous_count'],
        comeback_pattern_score: template_data['probability_components']['comeback_pattern'],
        continuous_pattern_score: template_data['probability_components']['continuous_pattern'],
        frequency_pattern_score: template_data['probability_components']['frequency_pattern'],
        recent_trend_score: template_data['probability_components']['recent_trend'],
        overall_probability: template_data['overall_probability'],
        confidence_level: template_data['confidence_level'],
        last_appearance: template_data['last_appearance'],
        prediction_date: prediction_date
      )
    end
  end

  def update_statistical_summaries(game_type)
    base_path = Rails.root.join("../../vloto/#{game_type}/json-data")
    
    # Update day of week summaries
    update_day_of_week_summaries(base_path.join('day-of-week-summary.json'), game_type)
    
    # Update month summaries
    update_month_summaries(base_path.join('month-summary.json'), game_type)
    
    # Update day of month summaries
    update_day_of_month_summaries(base_path.join('day-of-month-summary.json'), game_type)
    
    # Update even/odd summaries
    update_even_odd_summaries(base_path.join('even-odd-summary.json'), game_type)
  end

  def update_day_of_week_summaries(file_path, game_type)
    return unless File.exist?(file_path)
    
    data = JSON.parse(File.read(file_path))
    
    # Clear old data
    DayOfWeekSummary.where(game_type: game_type).delete_all
    
    data.each do |day_of_week, numbers|
      numbers.each do |number_data|
        DayOfWeekSummary.create!(
          game_type: game_type,
          day_of_week: day_of_week,
          number: number_data['number'],
          count: number_data['count'],
          percentage: number_data['percentage']
        )
      end
    end
  end

  def update_month_summaries(file_path, game_type)
    return unless File.exist?(file_path)
    
    data = JSON.parse(File.read(file_path))
    
    # Clear old data
    MonthSummary.where(game_type: game_type).delete_all
    
    data.each do |month, numbers|
      numbers.each do |number_data|
        MonthSummary.create!(
          game_type: game_type,
          month: month.to_i,
          number: number_data['number'],
          count: number_data['count'],
          percentage: number_data['percentage']
        )
      end
    end
  end

  def update_day_of_month_summaries(file_path, game_type)
    return unless File.exist?(file_path)
    
    data = JSON.parse(File.read(file_path))
    
    # Clear old data
    DayOfMonthSummary.where(game_type: game_type).delete_all
    
    data.each do |day_of_month, numbers|
      numbers.each do |number_data|
        DayOfMonthSummary.create!(
          game_type: game_type,
          day_of_month: day_of_month.to_i,
          number: number_data['number'],
          count: number_data['count'],
          percentage: number_data['percentage']
        )
      end
    end
  end

  def update_even_odd_summaries(file_path, game_type)
    return unless File.exist?(file_path)
    
    data = JSON.parse(File.read(file_path))
    
    # Clear old data
    EvenOddSummary.where(game_type: game_type).delete_all
    
    data.each do |even_odd_type, numbers|
      numbers.each do |number_data|
        EvenOddSummary.create!(
          game_type: game_type,
          even_odd_type: even_odd_type,
          number: number_data['number'],
          count: number_data['count'],
          percentage: number_data['percentage']
        )
      end
    end
  end

  def parse_vietnamese_date(date_str)
    # Parse Vietnamese date format like "T4, 27/08/2025"
    date_part = date_str.split(', ').last
    day, month, year = date_part.split('/').map(&:to_i)
    Date.new(year, month, day)
  rescue
    Date.current
  end
end
