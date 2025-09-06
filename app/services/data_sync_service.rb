require 'net/http'
require 'json'
require 'nokogiri'
require 'date'

class DataSyncService
  BASE_URLS = {
    'vietlot45' => 'https://www.ketquadientoan.com/tat-ca-ky-xo-so-mega-6-45.html',
    'vietlot55' => 'https://www.ketquadientoan.com/tat-ca-ky-xo-so-mega-6-55.html'
  }.freeze
  
  def initialize(game_type)
    @game_type = game_type
    @base_url = BASE_URLS[game_type]
    @total_numbers = game_type == 'vietlot45' ? 45 : 55
  end
  
  def sync_now
    Rails.logger.info "Starting sync for #{@game_type}"
    
    begin
      # Fetch new data
      new_data = fetch_lottery_data
      
      if new_data.any?
        # Process and save data
        process_and_save_data(new_data)
        
        # Generate predictions
        generate_predictions
        
        # Generate summaries
        generate_summaries
        
        Rails.logger.info "Sync completed for #{@game_type}: #{new_data.length} new records"
        return { success: true, records_added: new_data.length }
      else
        Rails.logger.info "No new data found for #{@game_type}"
        return { success: true, records_added: 0 }
      end
      
    rescue => e
      Rails.logger.error "Sync failed for #{@game_type}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return { success: false, error: e.message }
    end
  end
  
  private
  
  def fetch_lottery_data
    Rails.logger.info "Fetching data from: #{@base_url}"
    
    # Get date range
    start_date = '01-01-2016'
    end_date = Date.current.strftime('%d-%m-%Y')
    url = "#{@base_url}?datef=#{start_date}&datet=#{end_date}"
    
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    
    unless response.is_a?(Net::HTTPSuccess)
      raise "HTTP request failed: #{response.code} #{response.message}"
    end
    
    doc = Nokogiri::HTML(response.body)
    results = []
    
    doc.css('table.table-mini-result tr').each do |row|
      cols = row.css('td')
      next unless cols.length >= 3
      
      date_text = cols[0].text.strip
      numbers_text = cols[1].text.strip
      prize_text = cols[2].text.strip
      
      # Parse numbers using regex
      numbers = numbers_text.scan(/\b\d{1,2}\b/)
      
      if date_text.present? && numbers.length == 6 && prize_text.present?
        numbers_str = numbers.join(' ')
        total = calculate_total(numbers_str)
        total_even_or_odd = total.even? ? 'even' : 'odd'
        numeric_prize = extract_numeric_prize(prize_text)
        odd_count = count_odd_numbers(numbers_str)
        even_count = count_even_numbers(numbers_str)
        
        results << {
          date: date_text,
          numbers: numbers_str,
          prize_s: prize_text,
          prize: numeric_prize,
          total: total,
          total_even_or_odd: total_even_or_odd,
          odd_count: odd_count,
          even_count: even_count
        }
      end
    end
    
    Rails.logger.info "Fetched #{results.length} records for #{@game_type}"
    results
  end
  
  def process_and_save_data(new_data)
    Rails.logger.info "Processing and saving data for #{@game_type}"
    
    new_data.each do |data|
      # Parse date
      draw_date = parse_date(data[:date])
      
      # Check if record already exists
      existing = LotteryDraw.find_by(
        game_type: @game_type,
        draw_date: draw_date
      )
      
      next if existing
      
      # Create new lottery draw record
      lottery_draw = LotteryDraw.create!(
        game_type: @game_type,
        draw_date: draw_date,
        date_string: data[:date],
        numbers: data[:numbers],
        prize_string: data[:prize_s],
        prize_amount: data[:prize],
        total: data[:total],
        total_even_or_odd: data[:total_even_or_odd],
        odd_count: data[:odd_count],
        even_count: data[:even_count],
        template_id: generate_template_id(data[:numbers])
      )
      
      # Generate predictions for this draw
      generate_predictions_for_draw(lottery_draw)
    end
  end
  
  def generate_predictions
    Rails.logger.info "Generating predictions for #{@game_type}"
    
    # Get all draws for this game type
    draws = LotteryDraw.where(game_type: @game_type).order(draw_date: :desc)
    
    # Clear existing predictions
    Prediction.where(game_type: @game_type).delete_all
    
    # Generate new predictions using frequency analysis
    frequency_data = calculate_frequency_analysis(draws)
    
    frequency_data.each do |number, data|
      Prediction.create!(
        game_type: @game_type,
        number: number,
        score: data[:score],
        trend: determine_trend(data[:frequency]),
        strength: data[:score],
        confidence: determine_confidence(data[:score]),
        forecast: data[:score],
        prediction_date: Time.current
      )
    end
  end
  
  def generate_summaries
    Rails.logger.info "Generating summaries for #{@game_type}"
    
    draws = LotteryDraw.where(game_type: @game_type)
    
    # Generate day of week summaries
    generate_day_of_week_summaries(draws)
    
    # Generate month summaries
    generate_month_summaries(draws)
    
    # Generate day of month summaries
    generate_day_of_month_summaries(draws)
    
    # Generate even/odd summaries
    generate_even_odd_summaries(draws)
  end
  
  def generate_day_of_week_summaries(draws)
    DayOfWeekSummary.where(game_type: @game_type).delete_all
    
    day_names = %w[sun mon tue wed thu fri sat]
    
    day_names.each do |day|
      day_draws = draws.select { |draw| draw.draw_date.wday == day_names.index(day) }
      
      (1..@total_numbers).each do |number|
        count = day_draws.count { |draw| draw.numbers_array.include?(number) }
        percentage = day_draws.any? ? (count.to_f / day_draws.length * 100).round(1) : 0
        
        DayOfWeekSummary.create!(
          game_type: @game_type,
          day_of_week: day,
          number: number,
          count: count,
          percentage: percentage
        )
      end
    end
  end
  
  def generate_month_summaries(draws)
    MonthSummary.where(game_type: @game_type).delete_all
    
    (1..12).each do |month|
      month_draws = draws.select { |draw| draw.draw_date.month == month }
      
      (1..@total_numbers).each do |number|
        count = month_draws.count { |draw| draw.numbers_array.include?(number) }
        percentage = month_draws.any? ? (count.to_f / month_draws.length * 100).round(1) : 0
        
        MonthSummary.create!(
          game_type: @game_type,
          month: month,
          number: number,
          count: count,
          percentage: percentage
        )
      end
    end
  end
  
  def generate_day_of_month_summaries(draws)
    DayOfMonthSummary.where(game_type: @game_type).delete_all
    
    (1..31).each do |day|
      day_draws = draws.select { |draw| draw.draw_date.day == day }
      
      (1..@total_numbers).each do |number|
        count = day_draws.count { |draw| draw.numbers_array.include?(number) }
        percentage = day_draws.any? ? (count.to_f / day_draws.length * 100).round(1) : 0
        
        DayOfMonthSummary.create!(
          game_type: @game_type,
          day_of_month: day,
          number: number,
          count: count,
          percentage: percentage
        )
      end
    end
  end
  
  def generate_even_odd_summaries(draws)
    EvenOddSummary.where(game_type: @game_type).delete_all
    
    %w[even odd].each do |type|
      type_draws = draws.select { |draw| draw.draw_date.day.send("#{type}?") }
      
      (1..@total_numbers).each do |number|
        count = type_draws.count { |draw| draw.numbers_array.include?(number) }
        percentage = type_draws.any? ? (count.to_f / type_draws.length * 100).round(1) : 0
        
        EvenOddSummary.create!(
          game_type: @game_type,
          even_odd_type: type,
          number: number,
          count: count,
          percentage: percentage
        )
      end
    end
  end
  
  def calculate_frequency_analysis(draws)
    frequency_data = {}
    
    (1..@total_numbers).each do |number|
      appearances = draws.count { |draw| draw.numbers_array.include?(number) }
      last_appearance = draws.find { |draw| draw.numbers_array.include?(number) }&.draw_date
      
      # Calculate score based on frequency and recency
      frequency = draws.any? ? (appearances.to_f / draws.length * 100).round(1) : 0
      recency_score = last_appearance ? calculate_recency_score(last_appearance) : 0
      score = (frequency * 0.7 + recency_score * 0.3).round(2)
      
      frequency_data[number] = {
        frequency: frequency,
        score: score,
        last_appearance: last_appearance
      }
    end
    
    frequency_data
  end
  
  def calculate_recency_score(last_appearance)
    days_ago = (Date.current - last_appearance).to_i
    
    case days_ago
    when 0..7
      100
    when 8..30
      80
    when 31..90
      60
    when 91..180
      40
    when 181..365
      20
    else
      0
    end
  end
  
  def generate_predictions_for_draw(draw)
    # This would implement the template prediction logic
    # For now, we'll create a simple template ID
    template_id = "T#{draw.numbers_array.sum % 100}"
    draw.update(template_id: template_id)
  end
  
  def parse_date(date_str)
    # Handle format like "T4, 02/07/2025" or just "02/07/2025"
    date_part = date_str.include?(', ') ? date_str.split(', ')[1] : date_str
    day, month, year = date_part.split('/').map(&:to_i)
    Date.new(year, month, day)
  end
  
  def calculate_total(numbers_str)
    numbers_str.split(' ').map(&:to_i).sum
  end
  
  def extract_numeric_prize(prize_str)
    match = prize_str.match(/^([0-9.]+)/)
    match ? match[1].gsub('.', '') : '0'
  end
  
  def count_odd_numbers(numbers_str)
    numbers_str.split(' ').map(&:to_i).count(&:odd?)
  end
  
  def count_even_numbers(numbers_str)
    numbers_str.split(' ').map(&:to_i).count(&:even?)
  end
  
  def generate_template_id(numbers_str)
    # Simple template ID generation based on number patterns
    numbers = numbers_str.split(' ').map(&:to_i)
    pattern = numbers.map { |n| n.even? ? 'E' : 'O' }.join
    "T#{pattern.hash.abs % 100}"
  end
  
  def determine_trend(frequency)
    case frequency
    when 0..20
      'down'
    when 21..40
      'stable'
    else
      'up'
    end
  end
  
  def determine_confidence(score)
    case score
    when 0..30
      'low'
    when 31..70
      'medium'
    else
      'high'
    end
  end
end
