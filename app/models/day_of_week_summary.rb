class DayOfWeekSummary < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :day_of_week, presence: true, inclusion: { in: %w[sun mon tue wed thu fri sat] }
  validates :number, presence: true, numericality: { greater_than: 0 }
  validates :count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :by_day, ->(day) { where(day_of_week: day) }
  scope :by_number, ->(number) { where(number: number) }
  scope :most_frequent, -> { order(count: :desc) }
  scope :least_frequent, -> { order(count: :asc) }

  def self.day_names
    {
      'sun' => 'Sunday',
      'mon' => 'Monday', 
      'tue' => 'Tuesday',
      'wed' => 'Wednesday',
      'thu' => 'Thursday',
      'fri' => 'Friday',
      'sat' => 'Saturday'
    }
  end

  def day_name
    self.class.day_names[day_of_week]
  end

  def self.top_numbers_for_day(game_type, day_of_week, limit = 10)
    where(game_type: game_type, day_of_week: day_of_week)
      .order(count: :desc)
      .limit(limit)
  end

  def self.number_frequency_by_day(game_type, number)
    where(game_type: game_type, number: number)
      .order(:day_of_week)
  end

  def self.days_with_most_appearances(game_type, number)
    where(game_type: game_type, number: number)
      .order(count: :desc)
  end

  def frequency_level
    return 'none' if count == 0
    return 'low' if count <= 10
    return 'medium' if count <= 50
    'high'
  end
end
