class DataUpdateJob < ApplicationJob
  queue_as :default

  def perform(game_type = nil)
    if game_type
      update_game_data(game_type)
    else
      update_game_data('vietlot45')
      update_game_data('vietlot55')
    end
  end

  private

  def update_game_data(game_type)
    Rails.logger.info "Starting data update for #{game_type}"
    
    # Use the existing DataSyncService
    sync_service = DataSyncService.new(game_type)
    result = sync_service.sync_now
    
    if result[:success]
      Rails.logger.info "Completed data update for #{game_type}: #{result[:records_added]} records processed"
    else
      Rails.logger.error "Data update failed for #{game_type}: #{result[:error]}"
    end
  end

end
