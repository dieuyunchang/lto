class DayOfMonthSummary < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :day_of_month, presence: true, numericality: { in: 1..31 }
  validates :number, presence: true, numericality: { greater_than: 0 }
  validates :count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :by_day_of_month, ->(day) { where(day_of_month: day) }
  scope :by_number, ->(number) { where(number: number) }
  scope :most_frequent, -> { order(count: :desc) }
  scope :least_frequent, -> { order(count: :asc) }

  def self.top_numbers_for_day_of_month(game_type, day_of_month, limit = 10)
    where(game_type: game_type, day_of_month: day_of_month)
      .order(count: :desc)
      .limit(limit)
  end

  def self.number_frequency_by_day_of_month(game_type, number)
    where(game_type: game_type, number: number)
      .order(:day_of_month)
  end

  def self.days_with_most_appearances(game_type, number)
    where(game_type: game_type, number: number)
      .order(count: :desc)
  end

  def self.week_analysis(game_type, number)
    week1 = where(game_type: game_type, number: number, day_of_month: 1..7).sum(:count)
    week2 = where(game_type: game_type, number: number, day_of_month: 8..14).sum(:count)
    week3 = where(game_type: game_type, number: number, day_of_month: 15..21).sum(:count)
    week4 = where(game_type: game_type, number: number, day_of_month: 22..28).sum(:count)
    week5 = where(game_type: game_type, number: number, day_of_month: 29..31).sum(:count)
    
    {
      week1: week1,
      week2: week2,
      week3: week3,
      week4: week4,
      week5: week5
    }
  end

  def frequency_level
    return 'none' if count == 0
    return 'low' if count <= 2
    return 'medium' if count <= 8
    'high'
  end

  def week_of_month
    case day_of_month
    when 1..7 then 1
    when 8..14 then 2
    when 15..21 then 3
    when 22..28 then 4
    else 5
    end
  end
end
