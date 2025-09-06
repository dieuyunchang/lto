class Api::V1::LotteryDrawsController < Api::V1::BaseController
  before_action :set_game_type, only: [:vietlot45, :vietlot55]

  def index
    @draws = LotteryDraw.all
    @draws = @draws.where(game_type: params[:game_type]) if params[:game_type].present?
    @draws = @draws.recent.limit(params[:limit] || 50)
    
    render_success(@draws)
  end

  def show
    @draw = LotteryDraw.find(params[:id])
    render_success(@draw)
  rescue ActiveRecord::RecordNotFound
    render_error('Lottery draw not found', :not_found)
  end

  def vietlot45
    @draws = LotteryDraw.vietlot45.recent.limit(params[:limit] || 50)
    render_success(@draws)
  end

  def vietlot55
    @draws = LotteryDraw.vietlot55.recent.limit(params[:limit] || 50)
    render_success(@draws)
  end

  private

  def set_game_type
    @game_type = action_name == 'vietlot45' ? 'vietlot45' : 'vietlot55'
  end
end
