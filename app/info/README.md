# Vloto Rails - Lottery Prediction System

A comprehensive Ruby on Rails application for lottery number prediction and analysis, built with PostgreSQL database storage. This system provides AI-powered predictions, statistical analysis, and a modern web interface for Vietlott lottery games.

## Features

🎯 **AI-Powered Predictions** - Advanced forecasting using historical data trends  
📊 **Statistical Analysis** - Frequency analysis by day, month, and date patterns  
🔢 **Smart Number Generation** - Avoids duplicate combinations and common patterns  
📱 **Responsive Design** - Works on desktop and mobile devices  
⚡ **Real-time Updates** - Background job processing for data updates  
🗄️ **PostgreSQL Database** - Robust data storage with proper indexing  
🚀 **RESTful API** - Complete API for data access and integration  

## Technology Stack

- **Backend**: Ruby on Rails 7.1
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq
- **Frontend**: Bootstrap 5, Chart.js
- **API**: RESTful JSON API
- **Caching**: Redis (for Sidekiq)

## Database Schema

The application stores lottery data in the following tables:

### Core Tables
- `lottery_draws` - Historical lottery drawing data
- `predictions` - AI-generated number predictions
- `template_predictions` - Template-based pattern predictions

### Statistical Analysis Tables
- `day_of_week_summaries` - Number frequency by day of week
- `month_summaries` - Number frequency by month
- `day_of_month_summaries` - Number frequency by day of month
- `even_odd_summaries` - Even/odd date analysis

## Installation

### Prerequisites
- Ruby 3.2.0 or higher
- PostgreSQL 12 or higher
- Redis (for background jobs)
- Node.js (for asset compilation)

### Setup

1. **Clone and navigate to the project:**
   ```bash
   cd vloto_rails
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Setup database:**
   ```bash
   # Create and setup database
   rails db:create
   rails db:migrate
   ```

4. **Import data from JSON files:**
   ```bash
   # Import all data
   rails data:import
   
   # Or import specific game data
   rails data:import_vietlot45
   rails data:import_vietlot55
   ```

5. **Start Redis (for background jobs):**
   ```bash
   redis-server
   ```

6. **Start the application:**
   ```bash
   # In one terminal - Rails server
   rails server
   
   # In another terminal - Sidekiq worker
   bundle exec sidekiq
   ```

7. **Access the application:**
   - **Web Interface**: http://localhost:3000
   - **API**: http://localhost:3000/api/v1/

## Usage

### Web Interface

- **Dashboard**: Overview of latest draws and predictions
- **Vietlot 45**: Detailed analysis for 6/45 game
- **Vietlot 55**: Detailed analysis for 6/55 game
- **Statistics**: Statistical analysis and charts
- **Predictions**: AI-powered number predictions

### API Endpoints

#### Lottery Draws
- `GET /api/v1/lottery_draws` - List all draws
- `GET /api/v1/lottery_draws/:id` - Get specific draw
- `GET /api/v1/vietlot45/draws` - Vietlot 45 draws
- `GET /api/v1/vietlot55/draws` - Vietlot 55 draws

#### Predictions
- `GET /api/v1/predictions` - List all predictions
- `GET /api/v1/predictions/top_predictions` - Top predictions
- `GET /api/v1/predictions/by_confidence` - Filter by confidence level

#### Template Predictions
- `GET /api/v1/template_predictions` - List template predictions
- `GET /api/v1/template_predictions/top_predictions` - Top template predictions
- `GET /api/v1/template_predictions/by_template` - Get by template ID

#### Statistical Analysis
- `GET /api/v1/day_of_week_summaries` - Day of week analysis
- `GET /api/v1/month_summaries` - Monthly analysis
- `GET /api/v1/day_of_month_summaries` - Day of month analysis
- `GET /api/v1/even_odd_summaries` - Even/odd analysis

### Background Jobs

The application uses Sidekiq for background processing:

```ruby
# Update all data
DataUpdateJob.perform_async

# Update specific game data
DataUpdateJob.perform_async('vietlot45')
DataUpdateJob.perform_async('vietlot55')
```

## Data Migration

The application includes comprehensive data migration scripts to import data from the original JSON files:

```bash
# Import all data
rails data:import

# Import specific game data
rails data:import_vietlot45
rails data:import_vietlot55
```

## Configuration

### Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string (default: redis://localhost:6379/0)
- `RAILS_ENV` - Environment (development, production, test)

### Database Configuration

The database configuration is in `config/database.yml`. Update the connection parameters as needed for your environment.

## Development

### Running Tests
```bash
rails test
```

### Code Quality
```bash
# RuboCop linting
bundle exec rubocop

# Brakeman security scan
bundle exec brakeman
```

### Database Console
```bash
rails dbconsole
```

## API Documentation

The API follows RESTful conventions and returns JSON responses. All endpoints support filtering and pagination parameters.

### Response Format
```json
{
  "data": [...],
  "message": "Optional message"
}
```

### Error Format
```json
{
  "error": "Error message"
}
```

## Deployment

### Production Setup

1. **Environment Variables:**
   ```bash
   export RAILS_ENV=production
   export DATABASE_URL=postgresql://user:password@host:port/database
   export REDIS_URL=redis://host:port/0
   ```

2. **Database Setup:**
   ```bash
   rails db:create RAILS_ENV=production
   rails db:migrate RAILS_ENV=production
   rails data:import RAILS_ENV=production
   ```

3. **Asset Compilation:**
   ```bash
   rails assets:precompile RAILS_ENV=production
   ```

4. **Start Services:**
   ```bash
   # Rails server
   rails server -e production
   
   # Sidekiq worker
   bundle exec sidekiq -e production
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues or questions:
1. Check the Rails logs
2. Verify database connectivity
3. Ensure Redis is running for background jobs
4. Check that JSON data files are accessible

## Performance Considerations

- Database indexes are optimized for common queries
- Background jobs prevent blocking the main application
- Caching strategies can be implemented for frequently accessed data
- API responses are paginated for large datasets
