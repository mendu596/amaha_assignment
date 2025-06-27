A Ruby on Rails application that filters customers within a 100km radius of an office location using geographic coordinates.

## Prerequisites

Before setting up the application, ensure you have the following installed:

- **Ruby**: Version 3.2.2 or later
- **Bundler**: Ruby dependency manager

### Check Prerequisites
```bash
# Check Ruby version
ruby --version

# Install Bundler if not already installed
gem install bundler
```

## Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd amaha_assignment
```

### 2. Install Dependencies
```bash
# Install all required gems
bundle install
```

### 3. Verify Installation
```bash
# Check if all dependencies are satisfied
bundle check

# Verify Rails is working
rails --version
```
### 4. Environment Setup
```bash
# Copy the environment template
cp .env.example .env

# Edit the .env file with your credentials
# Set ADMIN_USER and ADMIN_PASSWORD for API authentication
nano .env
```

## Running the Server

### Start the Development Server
```bash
# Start the Rails server
rails server

# Or use the short form
rails s

# By default, Rails runs on port 3000
# To run on a different port (e.g., port 4000)
rails server -p 4000
```

### Verify the Server is Running
- Open your browser and navigate to `http://localhost:3000`
- The application will be available at this URL
- You can test the API endpoint at: `POST /customers/fetch_customer_details` on Postman or using `curl`

### Stop the Server
- Press `Ctrl + C` in the terminal where the server is running

## Authentication & Security

This application implements **HTTP Basic Authentication** to secure all API endpoints. Authentication is required for all requests to the customer filter API.

## Running Tests

### Run All Tests
```bash
# Execute the complete test suite
rails test

# Run tests with verbose output
rails test -v
```

### Run Specific Test Files
```bash
# Run controller tests
rails test test/controllers/customers_controller_test.rb

# Run service tests
rails test test/services/customer_filter_service_test.rb
```
### Test Coverage
```bash
# Run tests with coverage report
COVERAGE=true rails test

# View coverage report (opens in browser)
open coverage/index.html
```
