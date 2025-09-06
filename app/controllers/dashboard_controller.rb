class DashboardController < ApplicationController
  def index
    @vietlot45_latest = LotteryDraw.latest_draw('vietlot45')
    @vietlot55_latest = LotteryDraw.latest_draw('vietlot55')
    @vietlot45_recent = LotteryDraw.vietlot45.recent.limit(5)
    @vietlot55_recent = LotteryDraw.vietlot55.recent.limit(5)
  end

  def vietlot45
    @game_type = 'vietlot45'
    @latest_draw = LotteryDraw.latest_draw('vietlot45')
    @recent_draws = LotteryDraw.vietlot45.recent.limit(20)
    @latest_predictions = Prediction.latest_predictions('vietlot45')
    @template_predictions = TemplatePrediction.latest_predictions('vietlot45')
  end

  def vietlot55
    @game_type = 'vietlot55'
    @latest_draw = LotteryDraw.latest_draw('vietlot55')
    @recent_draws = LotteryDraw.vietlot55.recent.limit(20)
    @latest_predictions = Prediction.latest_predictions('vietlot55')
    @template_predictions = TemplatePrediction.latest_predictions('vietlot55')
  end

  def statistics
    @game_type = params[:game_type] || 'vietlot45'
    @day_of_week_stats = DayOfWeekSummary.where(game_type: @game_type).group(:day_of_week).sum(:count)
    @month_stats = MonthSummary.where(game_type: @game_type).group(:month).sum(:count)
    @even_odd_stats = EvenOddSummary.where(game_type: @game_type).group(:even_odd_type).sum(:count)
  end

  def predictions
    @game_type = params[:game_type] || 'vietlot45'
    @predictions = Prediction.latest_predictions(@game_type)
    @template_predictions = TemplatePrediction.latest_predictions(@game_type)
  end

end
