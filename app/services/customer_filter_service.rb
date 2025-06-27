# Service class to filter customers within a specified radius of an office location
# Processes JSON Lines formatted files and returns customers within 100km radius
#
# Usage:
#   service = CustomerFilterService.new(uploaded_file)
#   filtered_customers = service.call
#
# Expected file format: JSON Lines (.txt file with one JSON object per line)
# Example file content:
#   {"user_id": 1, "name": "John Doe", "latitude": "19.0760", "longitude": "72.8777"}
#   {"user_id": 2, "name": "Jane Smith", "latitude": "19.0596", "longitude": "72.7496"}
#
# Returns: Array of hashes with user_id and name, sorted by user_id
class CustomerFilterService
  # Office location coordinates (Mumbai, India - fixed reference point)
  OFFICE_LATITUDE = 19.0590317
  OFFICE_LONGITUDE = 72.7553452
  # Maximum distance in kilometers to include customers
  RADIUS_KM = 100

  attr_reader :customer_data_file

  # Initialize the service with a customer data file
  # @param customer_data_file [Object] File upload object with tempfile method (Rails ActionDispatch::Http::UploadedFile)
  # @raise [ArgumentError] if file input doesn't respond to tempfile method
  def initialize(customer_data_file)
    @customer_data_file = customer_data_file
  end

  # Main method to process customer data and return filtered results
  # Processes the uploaded file through the complete filtering pipeline:
  # 1. Parse JSON Lines from file
  # 2. Filter by distance from office
  # 3. Format and sort results
  # @return [Array<Hash>] Array of customer hashes with :user_id and :name keys, sorted by user_id
  # @raise [JSON::ParserError] if file contains invalid JSON
  def call
    parsed_customers = parse_customers_from_file
    customers_within_radius = filter_customers_within_radius(parsed_customers)
    sort_and_format_customers(customers_within_radius)
  end

  private

  # Parses customer data from JSON Lines format file
  # Each line should contain a valid JSON object with customer data
  # Automatically converts string keys to symbols for consistent access
  # Skips empty lines to handle file formatting variations
  # @return [Array<Hash>] Array of customer data with symbolized keys
  # @raise [JSON::ParserError] if any line contains invalid JSON
  def parse_customers_from_file
    customer_list = []
    customer_data_file.tempfile.each_line do |json_line|
      next if json_line.strip.empty?
      parsed_customer_data = JSON.parse(json_line)
      customer_list << parsed_customer_data.transform_keys(&:to_sym)
    end
    customer_list
  end

  # Filters customers to include only those within the specified radius
  # Uses Haversine formula to calculate great-circle distance
  # @param customer_list [Array<Hash>] Array of customer data with :latitude and :longitude
  # @return [Array<Hash>] Filtered array of customers within RADIUS_KM
  def filter_customers_within_radius(customer_list)
    customer_list.select do |customer|
      distance_from_office = calculate_distance_from_office(customer[:latitude].to_f, customer[:longitude].to_f)
      distance_from_office <= RADIUS_KM
    end
  end

  # Formats and sorts the final customer data for output
  # Only includes user_id and name fields to minimize response size
  # Sorts by user_id in ascending order for consistent output
  # @param customer_list [Array<Hash>] Array of filtered customers
  # @return [Array<Hash>] Formatted and sorted customer data with only :user_id and :name
  def sort_and_format_customers(customer_list)
    customer_list.map { |customer| customer.slice(:user_id, :name) }
                 .sort_by { |customer| customer[:user_id].to_i }
  end

  # Calculates the great-circle distance between office and customer locations
  # Uses the Haversine formula to determine distance in kilometers
  # Formula accounts for Earth's curvature for accurate geographic distances
  # @param customer_latitude [Float] Customer's latitude coordinate in decimal degrees
  # @param customer_longitude [Float] Customer's longitude coordinate in decimal degrees
  # @return [Float] Distance in kilometers between office and customer location
  def calculate_distance_from_office(customer_latitude, customer_longitude)
    earth_radius_km = 6371
    latitude_difference = degrees_to_radians(customer_latitude - OFFICE_LATITUDE)
    longitude_difference = degrees_to_radians(customer_longitude - OFFICE_LONGITUDE)
    haversine_formula = Math.sin(latitude_difference / 2)**2 +
        Math.cos(degrees_to_radians(OFFICE_LATITUDE)) * Math.cos(degrees_to_radians(customer_latitude)) * Math.sin(longitude_difference / 2)**2
    earth_radius_km * 2 * Math.asin(Math.sqrt(haversine_formula))
  end

  # Converts degrees to radians for trigonometric calculations
  # Required for Haversine formula which uses trigonometric functions
  # @param degree_value [Float] Angle in degrees
  # @return [Float] Angle in radians (degree_value * π / 180)
  def degrees_to_radians(degree_value)
    degree_value * Math::PI / 180
  end
end
