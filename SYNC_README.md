# LTO Rails - Lottery Prediction System

A comprehensive Ruby on Rails application for lottery data management, prediction, and analysis, featuring automated data synchronization similar to the original `update-all-data.js` functionality.

## Features

### 🎯 Core Functionality
- **Automated Data Sync**: Fetches lottery data from external sources automatically
- **AI Predictions**: Advanced number prediction using frequency analysis and pattern recognition
- **Template Analysis**: Sophisticated template-based prediction system
- **Real-time Statistics**: Comprehensive statistical analysis and visualization
- **Background Jobs**: Asynchronous data processing using Sidekiq
- **RESTful API**: Complete API for data access and integration

### 📊 Data Management
- **PostgreSQL Database**: Robust data storage with proper indexing
- **Data Models**: Complete models for lottery draws, predictions, and statistics
- **Data Validation**: Comprehensive data validation and error handling
- **Data Import**: Rake tasks for importing existing JSON data

### 🎨 User Interface
- **Modern Dashboard**: Bootstrap-based responsive interface
- **Interactive Charts**: Chart.js integration for data visualization
- **Real-time Updates**: Live sync status and activity monitoring
- **Mobile Responsive**: Optimized for all device sizes

## Setup Instructions

### Prerequisites
- Ruby 3.2.4+
- Rails 7.1.3+
- PostgreSQL 12+
- Redis (for background jobs)

### Installation

1. **Clone and Setup**
   ```bash
   cd /Users/yunchang/Workspace/lto
   bundle install
   ```

2. **Database Setup**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Import Existing Data** (Optional)
   ```bash
   rails import_json_data:all
   ```

4. **Start Services**
   ```bash
   # Start Redis (for background jobs)
   redis-server
   
   # Start Sidekiq (in another terminal)
   bundle exec sidekiq
   
   # Start Rails server
   rails server
   ```

## Data Synchronization

### Manual Sync
The application provides multiple ways to sync lottery data:

1. **Web Interface**
   - Navigate to `/sync` in your browser
   - Use manual sync buttons for individual games
   - Force sync for immediate updates

2. **Rake Tasks**
   ```bash
   # Schedule background sync jobs
   rails sync:schedule
   
   # Run immediate sync
   rails sync:run
   
   # Sync specific game
   rails "sync:run_game[vietlot45]"
   rails "sync:run_game[vietlot55]"
   
   # Check sync status
   rails sync:status
   ```

3. **Background Jobs**
   ```ruby
   # Queue sync jobs
   DataSyncJob.perform_later('vietlot45')
   DataSyncJob.perform_later('vietlot55')
   ```

### Automated Sync
Configure automated synchronization using cron jobs:

1. **Install Whenever Gem**
   ```bash
   gem install whenever
   ```

2. **Generate Cron Jobs**
   ```bash
   whenever --update-crontab
   ```

3. **Scheduled Tasks**
   - Every 6 hours: Background sync jobs
   - Daily at 2 AM: Full data sync
   - Weekdays at 8 AM & 6 PM: Scheduled sync
   - Hourly: Status checks

## API Endpoints

### Lottery Data
- `GET /api/v1/lottery_draws` - All lottery draws
- `GET /api/v1/lottery_draws/:id` - Specific draw
- `GET /api/v1/vietlot45/draws` - Vietlot 45 draws
- `GET /api/v1/vietlot55/draws` - Vietlot 55 draws

### Predictions
- `GET /api/v1/predictions` - All predictions
- `GET /api/v1/predictions/:id` - Specific prediction
- `GET /api/v1/vietlot45/predictions` - Vietlot 45 predictions
- `GET /api/v1/vietlot55/predictions` - Vietlot 55 predictions

### Statistics
- `GET /api/v1/day_of_week_summaries` - Day of week analysis
- `GET /api/v1/month_summaries` - Monthly analysis
- `GET /api/v1/day_of_month_summaries` - Day of month analysis
- `GET /api/v1/even_odd_summaries` - Even/odd analysis

### Sync Management
- `GET /sync` - Sync dashboard
- `POST /sync/manual` - Manual sync
- `POST /sync/force` - Force sync
- `GET /sync/status` - Sync status (JSON)

## Data Models

### LotteryDraw
- `game_type`: 'vietlot45' or 'vietlot55'
- `draw_date`: Date of the draw
- `numbers`: Lottery numbers as string
- `prize`: Numeric prize amount
- `template_id`: Associated template ID
- `total`, `odd_count`, `even_count`: Calculated fields

### Prediction
- `game_type`: Game type
- `number`: Predicted number
- `score`: Prediction confidence score
- `frequency`: Number frequency
- `last_appearance`: Last appearance date

### TemplatePrediction
- `template_id`: Template identifier
- `total_appearances`: Total template appearances
- `overall_probability`: Overall prediction probability
- `confidence_level`: Confidence rating

### Statistical Summaries
- `DayOfWeekSummary`: Analysis by day of week
- `MonthSummary`: Analysis by month
- `DayOfMonthSummary`: Analysis by day of month
- `EvenOddSummary`: Even/odd number analysis

## Sync Process

The sync process mirrors the original `update-all-data.js` functionality:

1. **Data Fetching**
   - Scrapes lottery data from external sources
   - Parses HTML using Nokogiri
   - Validates and cleans data

2. **Data Processing**
   - Calculates derived fields (totals, counts)
   - Generates template IDs
   - Updates tracking fields

3. **Prediction Generation**
   - Frequency analysis
   - Pattern recognition
   - Template-based predictions

4. **Statistical Analysis**
   - Day of week summaries
   - Monthly summaries
   - Even/odd analysis

5. **Database Updates**
   - Atomic transactions
   - Duplicate prevention
   - Error handling

## Configuration

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost/lto_development

# Redis
REDIS_URL=redis://localhost:6379/0

# Sync Settings
SYNC_INTERVAL=6.hours
SYNC_TIMEOUT=300.seconds
```

### Sidekiq Configuration
```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
```

## Monitoring

### Sync Status
- Real-time sync status monitoring
- Last sync timestamps
- Error tracking and reporting
- Activity logs

### Performance Metrics
- Sync duration tracking
- Records processed per sync
- Error rates and types
- Database performance metrics

## Troubleshooting

### Common Issues

1. **Sync Failures**
   ```bash
   # Check logs
   tail -f log/development.log
   
   # Test sync manually
   rails sync:run_game[vietlot45]
   ```

2. **Database Issues**
   ```bash
   # Reset database
   rails db:drop db:create db:migrate
   
   # Import data
   rails import_json_data:all
   ```

3. **Background Job Issues**
   ```bash
   # Check Sidekiq status
   bundle exec sidekiq-web
   
   # Clear failed jobs
   rails console
   Sidekiq::RetrySet.new.clear
   ```

### Log Files
- `log/development.log` - Application logs
- `log/sidekiq.log` - Background job logs
- `log/cron.log` - Scheduled task logs

## Development

### Adding New Features
1. Create models and migrations
2. Add controller actions
3. Create views and API endpoints
4. Add background jobs if needed
5. Update tests and documentation

### Testing
```bash
# Run tests
rails test

# Run specific tests
rails test test/models/lottery_draw_test.rb
```

## Production Deployment

### Requirements
- PostgreSQL database
- Redis server
- Sidekiq worker processes
- Cron job scheduler
- Web server (Nginx/Apache)

### Deployment Steps
1. Set up production database
2. Configure environment variables
3. Run migrations
4. Start background workers
5. Set up cron jobs
6. Configure web server

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
- Check the logs for error messages
- Review the API documentation
- Test sync functionality manually
- Check database connectivity
- Verify Redis and Sidekiq status
