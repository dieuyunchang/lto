namespace :sync do
  desc "Schedule data sync for both lottery games"
  task schedule: :environment do
    puts "🔄 Scheduling data sync jobs..."
    
    # Schedule sync for both games
    DataSyncJob.perform_later('vietlot45')
    DataSyncJob.perform_later('vietlot55')
    
    puts "✅ Data sync jobs scheduled successfully"
  end
  
  desc "Run immediate sync for both lottery games"
  task run: :environment do
    puts "🔄 Running immediate data sync..."
    
    begin
      # Run sync for both games
      DataSyncService.new('vietlot45').sync_now
      DataSyncService.new('vietlot55').sync_now
      
      puts "✅ Data sync completed successfully"
    rescue => e
      puts "❌ Data sync failed: #{e.message}"
      exit 1
    end
  end
  
  desc "Run sync for specific game type"
  task :run_game, [:game_type] => :environment do |t, args|
    game_type = args[:game_type] || 'both'
    
    puts "🔄 Running data sync for #{game_type}..."
    
    begin
      if game_type == 'both' || game_type == 'vietlot45'
        DataSyncService.new('vietlot45').sync_now
        puts "✅ Vietlot 45 sync completed"
      end
      
      if game_type == 'both' || game_type == 'vietlot55'
        DataSyncService.new('vietlot55').sync_now
        puts "✅ Vietlot 55 sync completed"
      end
      
      puts "✅ Data sync completed successfully"
    rescue => e
      puts "❌ Data sync failed: #{e.message}"
      exit 1
    end
  end
  
  desc "Check sync status"
  task status: :environment do
    puts "📊 Checking sync status..."
    
    %w[vietlot45 vietlot55].each do |game_type|
      latest_draw = LotteryDraw.where(game_type: game_type).order(draw_date: :desc).first
      
      if latest_draw
        days_since_last_draw = (Date.current - latest_draw.draw_date).to_i
        status = case days_since_last_draw
                 when 0..1
                   'Up to Date'
                 when 2..3
                   'Needs Update'
                 else
                   'Outdated'
                 end
        
        puts "#{game_type.upcase}: #{status} (Last draw: #{latest_draw.draw_date})"
      else
        puts "#{game_type.upcase}: No data available"
      end
    end
  end
  
  desc "Clear all sync data and start fresh"
  task reset: :environment do
    puts "🗑️  Clearing all sync data..."
    
    # Clear all data
    LotteryDraw.delete_all
    Prediction.delete_all
    TemplatePrediction.delete_all
    DayOfWeekSummary.delete_all
    MonthSummary.delete_all
    DayOfMonthSummary.delete_all
    EvenOddSummary.delete_all
    
    puts "✅ All sync data cleared"
    puts "🔄 Running fresh sync..."
    
    # Run fresh sync
    Rake::Task['sync:run'].invoke
  end
end
