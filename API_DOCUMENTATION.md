# Customer Filter API Documentation

## Overview
This API provides functionality to filter customers based on their proximity to a specified office location. It processes customer data from uploaded files and returns customers within a 100km radius, sorted by user ID.

## Base URL
```
http://localhost:3000
```

## Endpoints

### Filter Customers Within Radius

**Endpoint:** `POST /customers/fetch_customer_details`

**Description:** Filters customers within a 100km radius of the office location and returns them sorted by user ID.

#### Office Location (Fixed)
- **Latitude:** 19.0590317
- **Longitude:** 72.7553452
- **Radius:** 100km

#### Request

**Method:** POST

**Content-Type:** multipart/form-data

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| file | File | Yes | Text file containing customer data in JSON Lines format |

**File Format Requirements:**
- File extension: `.txt`
- Content format: JSON Lines (one JSON object per line)
- Each line must contain a valid JSON object with customer data

**Expected JSON Structure per line:**
```json
{"user_id": 1, "name": "John Doe", "latitude": "19.0760", "longitude": "72.8777"}
```

**Required Fields:**
- `user_id`: Unique identifier for the customer (number)
- `name`: Customer's full name (string)
- `latitude`: Customer's latitude coordinate (string or number)
- `longitude`: Customer's longitude coordinate (string or number)

**Sample Input File Content:**
```
{"user_id": 1, "name": "Vivaan Sharma", "latitude": "-68.850431", "longitude": "-35.814792"}
{"user_id": 2, "name": "Aditya Singh", "latitude": "82.784317", "longitude": "-11.291294"}
{"user_id": 3, "name": "Ayaan Reddy", "latitude": "-35.328826", "longitude": "134.432403"}
{"user_id": 4, "name": "Atharv Jain", "latitude": "-9.744095", "longitude": "96.547815"}
```

#### Response

**Success Response:**

**Status Code:** 200 OK

**Content-Type:** application/json

**Response Body:**
```json
[
  {
    "user_id": 1,
    "name": "Vivaan Sharma"
  },
  {
    "user_id": 2,
    "name": "Aditya Singh"
  },
  {
    "user_id": 3,
    "name": "Ayaan Reddy"
  }
]
```

**Response Format:**
- Array of customer objects
- Only customers within 100km radius are included
- Results are sorted by `user_id` in ascending order
- Only `user_id` and `name` fields are returned (other fields are filtered out)

**Error Responses:**

**400 Bad Request - No File Provided**
```json
{
  "error": "No file provided"
}
```

**400 Bad Request - Invalid File Format**
```json
{
  "error": "Invalid file format. Please upload a proper file."
}
```

**400 Bad Request - Invalid JSON Format**
```json
{
  "error": "Invalid JSON format in file"
}
```

**500 Internal Server Error**
```json
{
  "error": "An error occurred while processing the file"
}
```
