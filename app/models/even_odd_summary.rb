class EvenOddSummary < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :even_odd_type, presence: true, inclusion: { in: %w[even odd] }
  validates :number, presence: true, numericality: { greater_than: 0 }
  validates :count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :even_dates, -> { where(even_odd_type: 'even') }
  scope :odd_dates, -> { where(even_odd_type: 'odd') }
  scope :by_number, ->(number) { where(number: number) }
  scope :most_frequent, -> { order(count: :desc) }
  scope :least_frequent, -> { order(count: :asc) }

  def self.top_numbers_for_even_odd(game_type, even_odd_type, limit = 10)
    where(game_type: game_type, even_odd_type: even_odd_type)
      .order(count: :desc)
      .limit(limit)
  end

  def self.number_frequency_by_even_odd(game_type, number)
    where(game_type: game_type, number: number)
      .order(:even_odd_type)
  end

  def self.even_odd_comparison(game_type, number)
    even_count = where(game_type: game_type, number: number, even_odd_type: 'even').sum(:count)
    odd_count = where(game_type: game_type, number: number, even_odd_type: 'odd').sum(:count)
    
    {
      even_dates: even_count,
      odd_dates: odd_count,
      total: even_count + odd_count,
      even_percentage: even_count > 0 ? (even_count.to_f / (even_count + odd_count) * 100).round(2) : 0,
      odd_percentage: odd_count > 0 ? (odd_count.to_f / (even_count + odd_count) * 100).round(2) : 0
    }
  end

  def self.bias_analysis(game_type)
    numbers = (1..(game_type == 'vietlot45' ? 45 : 55)).to_a
    bias_results = {}
    
    numbers.each do |number|
      comparison = even_odd_comparison(game_type, number)
      bias_results[number] = {
        even_bias: comparison[:even_percentage] > 60,
        odd_bias: comparison[:odd_percentage] > 60,
        balanced: (comparison[:even_percentage] - comparison[:odd_percentage]).abs < 10,
        even_percentage: comparison[:even_percentage],
        odd_percentage: comparison[:odd_percentage]
      }
    end
    
    bias_results
  end

  def frequency_level
    return 'none' if count == 0
    return 'low' if count <= 20
    return 'medium' if count <= 80
    'high'
  end

  def even_odd_type_name
    even_odd_type.capitalize
  end
end
