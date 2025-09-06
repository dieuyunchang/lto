# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# Set environment
set :environment, Rails.env
set :output, Rails.root.join('log', 'cron.log')

# Schedule data sync every 6 hours
every 6.hours do
  rake "sync:schedule"
end

# Schedule data sync every day at 2 AM
every 1.day, at: '2:00 am' do
  rake "sync:run"
end

# Schedule data sync every weekday at 8 AM and 6 PM
every 1.day, at: ['8:00 am', '6:00 pm'], roles: [:app] do
  rake "sync:schedule"
end

# Schedule status check every hour
every 1.hour do
  rake "sync:status"
end
