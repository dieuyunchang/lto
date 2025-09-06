#!/bin/bash

# Vloto Rails Deployment Script
# This script helps deploy the Rails application

set -e

echo "🚀 Starting Vloto Rails deployment..."

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    echo "❌ Error: Gemfile not found. Please run this script from the Rails app root directory."
    exit 1
fi

# Check Ruby version
echo "📋 Checking Ruby version..."
ruby_version=$(ruby -v | cut -d' ' -f2 | cut -d'p' -f1)
required_version="3.2.0"

if [ "$(printf '%s\n' "$required_version" "$ruby_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Error: Ruby $required_version or higher is required. Current version: $ruby_version"
    exit 1
fi

echo "✅ Ruby version check passed"

# Install dependencies
echo "📦 Installing dependencies..."
bundle install

# Setup database
echo "🗄️ Setting up database..."
rails db:create
rails db:migrate

# Import data
echo "📊 Importing lottery data..."
if [ -d "../../vloto" ]; then
    rails data:import
    echo "✅ Data import completed"
else
    echo "⚠️ Warning: Original vloto directory not found. Skipping data import."
    echo "   To import data later, run: rails data:import"
fi

# Precompile assets (for production)
if [ "$RAILS_ENV" = "production" ]; then
    echo "🎨 Precompiling assets..."
    rails assets:precompile
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p log tmp/pids

echo "✅ Deployment completed successfully!"
echo ""
echo "🎯 Next steps:"
echo "   1. Start Redis: redis-server"
echo "   2. Start Rails server: rails server"
echo "   3. Start Sidekiq (in another terminal): bundle exec sidekiq"
echo "   4. Visit: http://localhost:3000"
echo ""
echo "📚 For more information, see README.md"
