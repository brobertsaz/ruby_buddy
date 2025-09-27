# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-09-26-enhanced-chat-interface/spec.md

> Created: 2025-09-26
> Version: 1.0.0

## Endpoints

### Message Status Management

#### Mark Message as Read
- **Method:** POST
- **Path:** `/messages/:id/mark_read`
- **Purpose:** Mark a specific message as read by the current user
- **Authentication:** Required
- **Parameters:**
  - `:id` (path) - Message ID (integer, required)
- **Request Body:** None
- **Response Format:**
  ```json
  {
    "status": "success",
    "message": "Message marked as read",
    "data": {
      "message_id": 123,
      "read_at": "2025-09-26T10:30:00Z"
    }
  }
  ```
- **Error Responses:**
  - 404: Message not found
  - 403: Unauthorized to mark this message as read
  - 422: Message already marked as read

### Typing Indicators

#### Send Typing Indicator for Mentorship Requests
- **Method:** POST
- **Path:** `/mentorship_requests/:id/typing`
- **Purpose:** Broadcast typing indicator to participants in a mentorship request conversation
- **Authentication:** Required
- **Parameters:**
  - `:id` (path) - Mentorship Request ID (integer, required)
- **Request Body:**
  ```json
  {
    "typing": true,
    "user_id": 456
  }
  ```
- **Response Format:**
  ```json
  {
    "status": "success",
    "message": "Typing indicator sent",
    "data": {
      "mentorship_request_id": 789,
      "user_id": 456,
      "typing": true,
      "timestamp": "2025-09-26T10:30:00Z"
    }
  }
  ```
- **Error Responses:**
  - 404: Mentorship request not found
  - 403: User not authorized to participate in this conversation

#### Send Typing Indicator for Direct Messages
- **Method:** POST
- **Path:** `/messages/typing`
- **Purpose:** Send typing indicator for direct message conversations
- **Authentication:** Required
- **Request Body:**
  ```json
  {
    "recipient_id": 123,
    "typing": true
  }
  ```
- **Response Format:**
  ```json
  {
    "status": "success",
    "message": "Typing indicator sent",
    "data": {
      "sender_id": 456,
      "recipient_id": 123,
      "typing": true,
      "timestamp": "2025-09-26T10:30:00Z"
    }
  }
  ```

### Message Status Updates

#### Get Message Status
- **Method:** GET
- **Path:** `/messages/:id/status`
- **Purpose:** Get current status of a message (sent, delivered, read)
- **Authentication:** Required
- **Parameters:**
  - `:id` (path) - Message ID (integer, required)
- **Response Format:**
  ```json
  {
    "status": "success",
    "data": {
      "message_id": 123,
      "status": "read",
      "sent_at": "2025-09-26T10:25:00Z",
      "delivered_at": "2025-09-26T10:25:01Z",
      "read_at": "2025-09-26T10:30:00Z"
    }
  }
  ```

#### Bulk Mark Messages as Read
- **Method:** POST
- **Path:** `/messages/bulk_mark_read`
- **Purpose:** Mark multiple messages as read in a single request
- **Authentication:** Required
- **Request Body:**
  ```json
  {
    "message_ids": [123, 124, 125],
    "conversation_type": "mentorship_request",
    "conversation_id": 789
  }
  ```
- **Response Format:**
  ```json
  {
    "status": "success",
    "message": "Messages marked as read",
    "data": {
      "marked_count": 3,
      "message_ids": [123, 124, 125],
      "read_at": "2025-09-26T10:30:00Z"
    }
  }
  ```

## Controllers

### MessagesController Additions
- **New Actions:**
  - `mark_read` - Handle individual message read status
  - `bulk_mark_read` - Handle bulk message read operations
  - `status` - Return message status information
  - `typing` - Handle typing indicators for direct messages

### MentorshipRequestsController Additions
- **New Actions:**
  - `typing` - Handle typing indicators for mentorship request conversations

### Real-time Broadcasting
- **ActionCable Integration:**
  - Typing indicators broadcast to conversation participants
  - Message status updates broadcast to sender
  - Read receipts broadcast to message sender

### Error Handling Standards
- **Authentication Errors:** 401 Unauthorized
- **Authorization Errors:** 403 Forbidden
- **Resource Not Found:** 404 Not Found
- **Validation Errors:** 422 Unprocessable Entity
- **Server Errors:** 500 Internal Server Error

### Response Format Standards
All API responses follow this structure:
```json
{
  "status": "success|error",
  "message": "Human readable message",
  "data": {},
  "errors": [] // Only present on error responses
}
```