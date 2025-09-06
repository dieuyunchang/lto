class MonthSummary < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :month, presence: true, numericality: { in: 1..12 }
  validates :number, presence: true, numericality: { greater_than: 0 }
  validates :count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :by_month, ->(month) { where(month: month) }
  scope :by_number, ->(number) { where(number: number) }
  scope :most_frequent, -> { order(count: :desc) }
  scope :least_frequent, -> { order(count: :asc) }

  def self.month_names
    {
      1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April',
      5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August',
      9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'
    }
  end

  def month_name
    self.class.month_names[month]
  end

  def self.top_numbers_for_month(game_type, month, limit = 10)
    where(game_type: game_type, month: month)
      .order(count: :desc)
      .limit(limit)
  end

  def self.number_frequency_by_month(game_type, number)
    where(game_type: game_type, number: number)
      .order(:month)
  end

  def self.months_with_most_appearances(game_type, number)
    where(game_type: game_type, number: number)
      .order(count: :desc)
  end

  def self.seasonal_analysis(game_type, number)
    spring = where(game_type: game_type, number: number, month: [3, 4, 5]).sum(:count)
    summer = where(game_type: game_type, number: number, month: [6, 7, 8]).sum(:count)
    autumn = where(game_type: game_type, number: number, month: [9, 10, 11]).sum(:count)
    winter = where(game_type: game_type, number: number, month: [12, 1, 2]).sum(:count)
    
    {
      spring: spring,
      summer: summer,
      autumn: autumn,
      winter: winter
    }
  end

  def frequency_level
    return 'none' if count == 0
    return 'low' if count <= 5
    return 'medium' if count <= 20
    'high'
  end
end
