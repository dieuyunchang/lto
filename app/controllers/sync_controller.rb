class SyncController < ApplicationController
  before_action :authenticate_admin, only: [:manual_sync, :force_sync]
  
  def index
    @last_sync_times = {
      vietlot45: get_last_sync_time('vietlot45'),
      vietlot55: get_last_sync_time('vietlot55')
    }
    
    @sync_status = {
      vietlot45: get_sync_status('vietlot45'),
      vietlot55: get_sync_status('vietlot55')
    }
  end
  
  def manual_sync
    game_type = params[:game_type] || 'both'
    
    begin
      if game_type == 'both' || game_type == 'vietlot45'
        DataSyncJob.perform_later('vietlot45')
        flash[:notice] = "Vietlot 45 sync job queued successfully"
      end
      
      if game_type == 'both' || game_type == 'vietlot55'
        DataSyncJob.perform_later('vietlot55')
        flash[:notice] = "Vietlot 55 sync job queued successfully"
      end
      
      if game_type == 'both'
        flash[:notice] = "Both lottery games sync jobs queued successfully"
      end
      
    rescue => e
      flash[:alert] = "Error queuing sync job: #{e.message}"
    end
    
    redirect_to sync_index_path
  end
  
  def force_sync
    game_type = params[:game_type] || 'both'
    
    begin
      if game_type == 'both' || game_type == 'vietlot45'
        DataSyncService.new('vietlot45').sync_now
        flash[:notice] = "Vietlot 45 force sync completed"
      end
      
      if game_type == 'both' || game_type == 'vietlot55'
        DataSyncService.new('vietlot55').sync_now
        flash[:notice] = "Vietlot 55 force sync completed"
      end
      
      if game_type == 'both'
        flash[:notice] = "Both lottery games force sync completed"
      end
      
    rescue => e
      flash[:alert] = "Error during force sync: #{e.message}"
    end
    
    redirect_to sync_index_path
  end
  
  def sync_status
    render json: {
      vietlot45: get_sync_status('vietlot45'),
      vietlot55: get_sync_status('vietlot55'),
      last_sync: {
        vietlot45: get_last_sync_time('vietlot45'),
        vietlot55: get_last_sync_time('vietlot55')
      }
    }
  end
  
  private
  
  def authenticate_admin
    # Simple admin authentication - you can implement proper authentication later
    unless session[:admin] || Rails.env.development?
      flash[:alert] = "Admin access required"
      redirect_to root_path
    end
  end
  
  def get_last_sync_time(game_type)
    # Get the latest draw date as a proxy for last sync time
    latest_draw = LotteryDraw.where(game_type: game_type).order(draw_date: :desc).first
    latest_draw&.draw_date
  end
  
  def get_sync_status(game_type)
    latest_draw = LotteryDraw.where(game_type: game_type).order(draw_date: :desc).first
    return 'no_data' unless latest_draw
    
    days_since_last_draw = (Date.current - latest_draw.draw_date).to_i
    
    case days_since_last_draw
    when 0..1
      'up_to_date'
    when 2..3
      'needs_update'
    else
      'outdated'
    end
  end
end
