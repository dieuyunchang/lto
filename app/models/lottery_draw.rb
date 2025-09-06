class LotteryDraw < ApplicationRecord
  validates :game_type, presence: true, inclusion: { in: %w[vietlot45 vietlot55] }
  validates :draw_date, presence: true
  validates :date_string, presence: true
  validates :numbers, presence: true
  validates :prize_amount, presence: true, numericality: { greater_than: 0 }
  validates :prize_string, presence: true
  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :total_even_or_odd, presence: true, inclusion: { in: %w[odd even] }
  validates :odd_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :even_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :template_id, presence: true
  validates :template_appear_comback_from_prev_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :template_continuos_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :template_appear_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :game_type, uniqueness: { scope: :draw_date }

  scope :vietlot45, -> { where(game_type: 'vietlot45') }
  scope :vietlot55, -> { where(game_type: 'vietlot55') }
  scope :recent, -> { order(draw_date: :desc) }
  scope :by_template, ->(template_id) { where(template_id: template_id) }

  def numbers_array
    numbers.split(' ').map(&:to_i)
  end

  def formatted_prize
    prize_string
  end

  def formatted_date
    date_string
  end

  def self.latest_draw(game_type)
    where(game_type: game_type).order(draw_date: :desc).first
  end

  def self.template_frequency(game_type, template_id)
    where(game_type: game_type, template_id: template_id).count
  end

  def self.template_last_appearance(game_type, template_id)
    where(game_type: game_type, template_id: template_id)
      .order(draw_date: :desc)
      .first&.draw_date
  end
end
