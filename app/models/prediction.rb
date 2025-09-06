class Prediction < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :number, presence: true, numericality: { greater_than: 0 }
  validates :score, presence: true, numericality: true
  validates :trend, presence: true, inclusion: { in: %w[up down stable] }
  validates :strength, presence: true, numericality: true
  validates :confidence, presence: true, inclusion: { in: %w[high medium low] }
  validates :forecast, presence: true, numericality: true
  validates :prediction_date, presence: true

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :high_confidence, -> { where(confidence: 'high') }
  scope :medium_confidence, -> { where(confidence: 'medium') }
  scope :low_confidence, -> { where(confidence: 'low') }
  scope :by_trend, ->(trend) { where(trend: trend) }
  scope :latest, -> { order(prediction_date: :desc) }

  def self.top_predictions(game_type, limit = 10)
    where(game_type: game_type)
      .order(score: :desc)
      .limit(limit)
  end

  def self.by_confidence_level(game_type, confidence_level)
    where(game_type: game_type, confidence: confidence_level)
      .order(score: :desc)
  end

  def self.latest_predictions(game_type)
    latest_date = where(game_type: game_type).maximum(:prediction_date)
    where(game_type: game_type, prediction_date: latest_date)
  end

  def confidence_score
    case confidence
    when 'high' then 3
    when 'medium' then 2
    when 'low' then 1
    else 0
    end
  end

  def trend_direction
    case trend
    when 'up' then '↗'
    when 'down' then '↘'
    when 'stable' then '→'
    else '?'
    end
  end
end
