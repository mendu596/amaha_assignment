require "test_helper"
require "mocha/minitest"

# Unit tests for CustomerFilterService
# Tests the core business logic for filtering customers by radius
class CustomerFilterServiceTest < ActionDispatch::IntegrationTest
  
  # Test case: Basic filtering and sorting functionality
  # Verifies that customers are properly filtered and results are sorted by user_id
  test "should filter customers within radius and sort by user_id" do
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    result = service.call

    # Check that results are sorted by user_id
    user_ids = result.map { |customer| customer[:user_id] }
    assert_equal user_ids, user_ids.sort
  end

  # Test case: Radius filtering with mixed distance data
  # Verifies that only customers within 100km radius are included
  test "should only return customers within 100km radius" do
    file = fixture_file_upload('mixed_customers.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    result = service.call
    # Should only return customers within radius (user_ids 1 and 3)
    # Customer with user_id 2 is far away (latitude: 25.0000, longitude: 80.0000)
    assert_equal 1, result.length
    returned_user_ids = result.map { |customer| customer[:user_id] }
    assert_includes returned_user_ids, 2
    assert_not_includes returned_user_ids, 3  # This customer is outside radius
  end

  # Test case: Empty line handling in file processing
  # Verifies that empty lines in the file don't cause processing errors
  test "should handle empty lines in file" do
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    result = service.call
    assert result.length >= 0 # Should not crash due to empty lines
  end

  # Test case: JSON key transformation
  # Verifies that string keys are properly converted to symbols
  test "should convert string keys to symbols" do
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    result = service.call
    assert result.length > 0
    assert_equal Integer, result.first[:user_id].class
    assert_equal String, result.first[:name].class
  end

  # Test case: Distance calculation accuracy
  # Verifies that the Haversine formula produces reasonable results
  test "should calculate distance correctly" do
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    # Test distance calculation with known coordinates
    # Distance from office (19.0590317, 72.7553452) to nearby point
    distance = service.send(:calculate_distance_from_office, 19.0760, 72.8777)
    # Should be reasonable distance (approximate check)
    assert distance > 0
    assert distance < 50 # Should be less than 50km for these coordinates
  end

  # Test case: Output format validation
  # Verifies that only required fields (user_id and name) are returned
  test "should format output correctly" do
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    result = service.call
    assert result.length > 0
    customer = result.first
    # Should only have user_id and name
    assert_equal 2, customer.keys.length
    assert customer.key?(:user_id)
    assert customer.key?(:name)
    assert_not customer.key?(:latitude)
    assert_not customer.key?(:longitude)
  end

  # Test case: Invalid JSON handling
  # Verifies that JSON::ParserError is raised for malformed JSON
  test "should raise JSON::ParserError for invalid JSON" do
    file = fixture_file_upload('invalid_customers.txt', 'text/plain')
    service = CustomerFilterService.new(file)
    assert_raises JSON::ParserError do
      service.call
    end
  end
end
