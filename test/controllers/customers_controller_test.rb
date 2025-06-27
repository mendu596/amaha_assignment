require 'test_helper'
require 'mocha/minitest'

# Integration tests for CustomersController
# Tests the /customers/fetch_customer_details endpoint with various scenarios
class CustomersControllerTest < ActionDispatch::IntegrationTest
  
  # Set up authentication headers for all tests
  def setup
    @auth_headers = {
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('durga_prasad', 'Password123')
    }
  end

  # Test case: Missing authentication
  # Verifies that the endpoint returns a 401 error when no authentication is provided
  test "fetch customer details returns unauthorized when no authentication provided" do
    post '/customers/fetch_customer_details', params: { file: nil }
    assert_response :unauthorized
  end

  # Test case: Invalid authentication
  # Verifies that the endpoint returns a 401 error when invalid credentials are provided
  test "fetch customer details returns unauthorized when invalid authentication provided" do
    invalid_auth_headers = {
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('wrong_user', 'wrong_password')
    }
    post '/customers/fetch_customer_details', params: { file: nil }, headers: invalid_auth_headers
    assert_response :unauthorized
  end

  # Test case: Missing file parameter
  # Verifies that the endpoint returns a 400 error when no file is provided
  test "fetch customer details returns error when no file provided" do
    post '/customers/fetch_customer_details', params: { file: nil }, headers: @auth_headers
    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_equal "No file provided", response_data["error"]
  end

  # Test case: Invalid file format (non-file parameter)
  # Verifies that the endpoint returns a 400 error when invalid data type is provided
  test "fetch customer details returns error when invalid file format provided" do
    post '/customers/fetch_customer_details', params: { file: 1234 }, headers: @auth_headers
    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_equal "Invalid file format. Please upload a proper file.", response_data["error"]
  end

  # Test case: Valid file upload with customer data
  # Verifies successful processing of customer data and proper response format
  test "fetch customer details returns filtered customers when valid file provided" do
    # Use file upload from fixture
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    post '/customers/fetch_customer_details', params: { file: file }, headers: @auth_headers
    assert_response :ok
    response_data = JSON.parse(response.body)
    # Verify the customers are sorted by user_id
    user_ids = response_data.map { |customer| customer["user_id"] }
    assert_equal user_ids, user_ids.sort
  end

  # Test case: Invalid JSON format in uploaded file
  # Verifies that malformed JSON in the file is handled gracefully
  test "fetch customer details handles json parser error" do
    # Use file upload with invalid JSON file
    file = fixture_file_upload('invalid_customers.txt', 'text/plain')
    post '/customers/fetch_customer_details', params: { file: file }, headers: @auth_headers
    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_equal "Invalid JSON format in file", response_data["error"]
  end

  # Test case: Unexpected service errors
  # Verifies that unexpected errors are logged and return a generic error message
  test "fetch customer details handles standard error" do
    # Mock the service to raise an error
    CustomerFilterService.stubs(:new).raises(StandardError, "Service error")
    # Use file upload
    file = fixture_file_upload('customers_within_radius.txt', 'text/plain')
    post '/customers/fetch_customer_details', params: { file: file }, headers: @auth_headers
    assert_response :internal_server_error
    response_data = JSON.parse(response.body)
    assert_equal "An error occurred while processing the file", response_data["error"]
  end

  # Test case: Radius filtering functionality
  # Verifies that customers outside the 100km radius are properly filtered out
  test "fetch customer details filters out customers outside radius" do
    # Use file upload with mixed data (some within radius, some outside)
    file = fixture_file_upload('mixed_customers.txt', 'text/plain')
    post '/customers/fetch_customer_details', params: { file: file }, headers: @auth_headers
    assert_response :ok
    response_data = JSON.parse(response.body)
    # Should only return customers within radius (user_ids 1 and 3)
    # Customer with user_id 2 is far away (latitude: 25.0000, longitude: 80.0000)
    assert_equal 1, response_data.length
    returned_user_ids = response_data.map { |customer| customer["user_id"] }
    assert_includes returned_user_ids, 2
    assert_not_includes returned_user_ids, 3  # This customer is outside radius
  end
end
