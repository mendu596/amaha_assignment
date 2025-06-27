require "json"

class CustomersController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /customers/fetch_customer_details
  # Filters customers within a 100km radius of the office location
  # Expects a file upload containing customer data in JSON Lines format
  # Returns filtered customers sorted by user_id
  def fetch_customer_details
    customer_data_file = params[:file]

    # Validate that a file parameter is provided
    return render json: { error: "No file provided" }, status: :bad_request if customer_data_file.nil? || customer_data_file.blank?

    begin
      # Validate file upload format - must respond to tempfile method
      if customer_data_file.respond_to?(:tempfile)
        # Process the file through the customer filter service
        filtered_customers = CustomerFilterService.new(customer_data_file).call
      else
        # Return error for invalid file formats (e.g., strings, numbers)
        return render json: { error: "Invalid file format. Please upload a proper file." }, status: :bad_request
      end

      # Return successfully filtered customers
      render json: filtered_customers, status: :ok
    rescue JSON::ParserError
      # Handle malformed JSON in the uploaded file
      render json: { error: "Invalid JSON format in file" }, status: :bad_request
    rescue StandardError => e
      # Log unexpected errors for debugging
      Rails.logger.error "Error processing customer file: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Return generic error message to client
      render json: { error: "An error occurred while processing the file" }, status: :internal_server_error
    end
  end
end
