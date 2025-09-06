namespace :data do
  desc "Import lottery data from JSON files"
  task import: :environment do
    puts "Starting data import from JSON files..."
    
    # Import Vietlot45 data
    import_vietlot45_data
    import_vietlot55_data
    
    puts "Data import completed!"
  end

  desc "Import Vietlot45 data"
  task import_vietlot45: :environment do
    import_vietlot45_data
  end

  desc "Import Vietlot55 data"
  task import_vietlot55: :environment do
    import_vietlot55_data
  end

  private

  def import_vietlot45_data
    puts "Importing Vietlot45 data..."
    
    json_file = Rails.root.join('../../vloto/vietlot45/json-data/vietlot45-data.json')
    if File.exist?(json_file)
      import_lottery_draws(json_file, 'vietlot45')
    end
    
    # Import predictions
    predictions_file = Rails.root.join('../../vloto/vietlot45/json-data/predictions.json')
    if File.exist?(predictions_file)
      import_predictions(predictions_file, 'vietlot45')
    end
    
    # Import template predictions
    template_file = Rails.root.join('../../vloto/vietlot45/json-data/template-predictions.json')
    if File.exist?(template_file)
      import_template_predictions(template_file, 'vietlot45')
    end
    
    # Import statistical summaries
    import_statistical_summaries('vietlot45')
  end

  def import_vietlot55_data
    puts "Importing Vietlot55 data..."
    
    json_file = Rails.root.join('../../vloto/vietlot55/json-data/vietlot55-data.json')
    if File.exist?(json_file)
      import_lottery_draws(json_file, 'vietlot55')
    end
    
    # Import predictions
    predictions_file = Rails.root.join('../../vloto/vietlot55/json-data/predictions.json')
    if File.exist?(predictions_file)
      import_predictions(predictions_file, 'vietlot55')
    end
    
    # Import template predictions
    template_file = Rails.root.join('../../vloto/vietlot55/json-data/template-predictions.json')
    if File.exist?(template_file)
      import_template_predictions(template_file, 'vietlot55')
    end
    
    # Import statistical summaries
    import_statistical_summaries('vietlot55')
  end

  def import_lottery_draws(file_path, game_type)
    puts "Importing lottery draws for #{game_type}..."
    
    data = JSON.parse(File.read(file_path))
    
    data.each do |draw_data|
      # Parse date from Vietnamese format
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
    
    puts "Imported #{data.count} lottery draws for #{game_type}"
  end

  def import_predictions(file_path, game_type)
    puts "Importing predictions for #{game_type}..."
    
    data = JSON.parse(File.read(file_path))
    prediction_date = Time.current
    
    data['predictedNumbers'].each do |pred_data|
      Prediction.find_or_create_by(
        game_type: game_type,
        number: pred_data['number'],
        prediction_date: prediction_date
      ) do |prediction|
        prediction.score = pred_data['score']
        prediction.trend = pred_data['trend']
        prediction.strength = pred_data['strength']
        prediction.confidence = pred_data['confidence']
        prediction.forecast = pred_data['forecast']
      end
    end
    
    puts "Imported #{data['predictedNumbers'].count} predictions for #{game_type}"
  end

  def import_template_predictions(file_path, game_type)
    puts "Importing template predictions for #{game_type}..."
    
    data = JSON.parse(File.read(file_path))
    prediction_date = Time.current
    
    data['top_predictions'].each do |template_data|
      TemplatePrediction.find_or_create_by(
        game_type: game_type,
        template_id: template_data['template_id'],
        prediction_date: prediction_date
      ) do |template|
        template.total_appearances = template_data['total_appearances']
        template.days_since_last = template_data['days_since_last']
        template.current_continuous_count = template_data['current_continuous_count']
        template.average_comeback_interval = template_data['average_comeback_interval']
        template.max_continuous_count = template_data['max_continuous_count']
        template.comeback_pattern_score = template_data['probability_components']['comeback_pattern']
        template.continuous_pattern_score = template_data['probability_components']['continuous_pattern']
        template.frequency_pattern_score = template_data['probability_components']['frequency_pattern']
        template.recent_trend_score = template_data['probability_components']['recent_trend']
        template.overall_probability = template_data['overall_probability']
        template.confidence_level = template_data['confidence_level']
        template.last_appearance = template_data['last_appearance']
      end
    end
    
    puts "Imported #{data['top_predictions'].count} template predictions for #{game_type}"
  end

  def import_statistical_summaries(game_type)
    puts "Importing statistical summaries for #{game_type}..."
    
    base_path = Rails.root.join("../../vloto/#{game_type}/json-data")
    
    # Import day of week summaries
    day_of_week_file = base_path.join('day-of-week-summary.json')
    if File.exist?(day_of_week_file)
      import_day_of_week_summaries(day_of_week_file, game_type)
    end
    
    # Import month summaries
    month_file = base_path.join('month-summary.json')
    if File.exist?(month_file)
      import_month_summaries(month_file, game_type)
    end
    
    # Import day of month summaries
    day_of_month_file = base_path.join('day-of-month-summary.json')
    if File.exist?(day_of_month_file)
      import_day_of_month_summaries(day_of_month_file, game_type)
    end
    
    # Import even/odd summaries
    even_odd_file = base_path.join('even-odd-summary.json')
    if File.exist?(even_odd_file)
      import_even_odd_summaries(even_odd_file, game_type)
    end
  end

  def import_day_of_week_summaries(file_path, game_type)
    data = JSON.parse(File.read(file_path))
    
    data.each do |day_of_week, numbers|
      numbers.each do |number_data|
        DayOfWeekSummary.find_or_create_by(
          game_type: game_type,
          day_of_week: day_of_week,
          number: number_data['number']
        ) do |summary|
          summary.count = number_data['count']
          summary.percentage = number_data['percentage']
        end
      end
    end
    
    puts "Imported day of week summaries for #{game_type}"
  end

  def import_month_summaries(file_path, game_type)
    data = JSON.parse(File.read(file_path))
    
    data.each do |month, numbers|
      numbers.each do |number_data|
        MonthSummary.find_or_create_by(
          game_type: game_type,
          month: month.to_i,
          number: number_data['number']
        ) do |summary|
          summary.count = number_data['count']
          summary.percentage = number_data['percentage']
        end
      end
    end
    
    puts "Imported month summaries for #{game_type}"
  end

  def import_day_of_month_summaries(file_path, game_type)
    data = JSON.parse(File.read(file_path))
    
    data.each do |day_of_month, numbers|
      numbers.each do |number_data|
        DayOfMonthSummary.find_or_create_by(
          game_type: game_type,
          day_of_month: day_of_month.to_i,
          number: number_data['number']
        ) do |summary|
          summary.count = number_data['count']
          summary.percentage = number_data['percentage']
        end
      end
    end
    
    puts "Imported day of month summaries for #{game_type}"
  end

  def import_even_odd_summaries(file_path, game_type)
    data = JSON.parse(File.read(file_path))
    
    data.each do |even_odd_type, numbers|
      numbers.each do |number_data|
        EvenOddSummary.find_or_create_by(
          game_type: game_type,
          even_odd_type: even_odd_type,
          number: number_data['number']
        ) do |summary|
          summary.count = number_data['count']
          summary.percentage = number_data['percentage']
        end
      end
    end
    
    puts "Imported even/odd summaries for #{game_type}"
  end

  def parse_vietnamese_date(date_str)
    # Parse Vietnamese date format like "T4, 27/08/2025"
    # Remove day abbreviation and parse the date part
    date_part = date_str.split(', ').last
    day, month, year = date_part.split('/').map(&:to_i)
    Date.new(year, month, day)
  rescue
    # Fallback to current date if parsing fails
    Date.current
  end
end
