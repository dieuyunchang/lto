class TemplatePrediction < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :template_id, presence: true
  validates :total_appearances, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :days_since_last, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :current_continuous_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :average_comeback_interval, presence: true, numericality: { greater_than: 0 }
  validates :max_continuous_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :comeback_pattern_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :continuous_pattern_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :frequency_pattern_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :recent_trend_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :overall_probability, presence: true, numericality: { in: 0..100 }
  validates :confidence_level, presence: true, numericality: { in: 0..100 }
  validates :last_appearance, presence: true
  validates :prediction_date, presence: true

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :high_probability, -> { where('overall_probability >= 70') }
  scope :medium_probability, -> { where('overall_probability >= 40 AND overall_probability < 70') }
  scope :low_probability, -> { where('overall_probability < 40') }
  scope :high_confidence, -> { where('confidence_level >= 70') }
  scope :medium_confidence, -> { where('confidence_level >= 40 AND confidence_level < 70') }
  scope :low_confidence, -> { where('confidence_level < 40') }
  scope :latest, -> { order(prediction_date: :desc) }

  def self.top_predictions(game_type, limit = 10)
    where(game_type: game_type)
      .order(overall_probability: :desc, confidence_level: :desc)
      .limit(limit)
  end

  def self.by_template(game_type, template_id)
    where(game_type: game_type, template_id: template_id)
      .order(prediction_date: :desc)
  end

  def self.latest_predictions(game_type)
    latest_date = where(game_type: game_type).maximum(:prediction_date)
    where(game_type: game_type, prediction_date: latest_date)
  end

  def probability_level
    case overall_probability
    when 70..100 then 'high'
    when 40...70 then 'medium'
    else 'low'
    end
  end

  def confidence_level_name
    case confidence_level
    when 70..100 then 'high'
    when 40...70 then 'medium'
    else 'low'
    end
  end

  def total_score
    comeback_pattern_score + continuous_pattern_score + frequency_pattern_score + recent_trend_score
  end

  def overdue?
    days_since_last > average_comeback_interval * 1.5
  end

  def hot_template?
    current_continuous_count >= 2
  end
end
