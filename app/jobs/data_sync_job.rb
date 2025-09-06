class DataSyncJob < ApplicationJob
  queue_as :default

  def perform(game_type)
    Rails.logger.info "Starting data sync job for #{game_type}"
    
    begin
      service = DataSyncService.new(game_type)
      result = service.sync_now
      
      if result[:success]
        Rails.logger.info "Data sync completed for #{game_type}: #{result[:records_added]} records added"
        
        # Update the last sync timestamp
        update_last_sync_time(game_type)
        
        # Broadcast update to connected clients
        ActionCable.server.broadcast(
          "sync_updates_#{game_type}",
          {
            status: 'completed',
            game_type: game_type,
            records_added: result[:records_added],
            timestamp: Time.current
          }
        )
      else
        Rails.logger.error "Data sync failed for #{game_type}: #{result[:error]}"
        
        # Broadcast error to connected clients
        ActionCable.server.broadcast(
          "sync_updates_#{game_type}",
          {
            status: 'failed',
            game_type: game_type,
            error: result[:error],
            timestamp: Time.current
          }
        )
        
        raise "Data sync failed: #{result[:error]}"
      end
      
    rescue => e
      Rails.logger.error "Data sync job failed for #{game_type}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Broadcast error to connected clients
      ActionCable.server.broadcast(
        "sync_updates_#{game_type}",
        {
          status: 'failed',
          game_type: game_type,
          error: e.message,
          timestamp: Time.current
        }
      )
      
      raise e
    end
  end
  
  private
  
  def update_last_sync_time(game_type)
    # Store last sync time in Redis or database
    Rails.cache.write("last_sync_#{game_type}", Time.current, expires_in: 1.day)
  end
end
