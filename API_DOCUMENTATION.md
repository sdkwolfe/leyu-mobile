# API Documentation

## Overview

This document describes the API integration in Leyu Mobile app. The app communicates with a RESTful API for all backend operations.

## Base Configuration

### Environment Variables

API configuration is managed through environment variables:

```env
API_BASE_URL=http://your-api-url.com/api
```

See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for configuration details.

### API Client

**Location**: `lib/core/api/api_client.dart`

The API client is built on Dio with the following features:
- Automatic token management
- Request/response interceptors
- Error handling
- Timeout configuration
- Retry logic

## Authentication

### JWT Token Management

The app uses JWT (JSON Web Tokens) for authentication:

- **Access Token**: Short-lived token for API requests
- **Refresh Token**: Long-lived token for obtaining new access tokens

### Token Flow

```
1. User logs in
   ↓
2. Receive access + refresh tokens
   ↓
3. Store tokens securely
   ↓
4. Include access token in API requests
   ↓
5. On 401 error, refresh access token
   ↓
6. Retry original request
```

### Implementation

```dart
// Login
POST /iam/auth/mobile_login
Body: {
  "username": "+251912345678",
  "password": "password123",
  "device_token": "string",
  "device_type": "android"
}

Response: {
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": { ... }
}

// Refresh Token
POST /iam/auth/refresh-token
Body: {
  "refresh_token": "eyJhbGc..."
}

Response: {
  "data": {
    "access_token": "eyJhbGc...",
    "new_refresh_token": "eyJhbGc..."
  }
}
```

## API Endpoints

### Authentication Endpoints

#### Register
```
POST /iam/users/sign-up
Body: {
  "phone_number": "+251912345678"
}
Response: {
  "data": {
    "verification_id": "uuid"
  }
}
```

#### Activate Account
```
POST /iam/users/verify/:verificationId
Body: {
  "phone": "+251912345678",
  "code": "123456"
}
Response: {
  "data": {
    "accessToken": "...",
    "user": { ... }
  }
}
```

#### Register Profile
```
PATCH /iam/users
Body: FormData {
  "first_name": "John",
  "middle_name": "Doe",
  "last_name": "Smith",
  "email": "john@example.com",
  "password": "password123",
  "birth_date": "1990-01-01",
  "gender": "Male",
  "dialect_id": "uuid",
  "language_id": "uuid",
  "referral_code": "ABC123",   // optional
  "national_id": File          // optional
}
Response: {
  "success": true
}
```

#### Login
```
POST /iam/auth/mobile_login
Body: {
  "username": "+251912345678",
  "password": "password123",
  "device_token": "string",
  "device_type": "android"
}
Response: {
  "accessToken": "...",
  "refreshToken": "...",
  "user": { ... }
}
```

#### Request OTP (Password Reset)
```
POST /iam/auth/forgot-password
Body: {
  "username": "+251912345678"
}
Response: {
  "success": true
}
```

#### Verify OTP
```
POST /iam/auth/verify-otp
Body: {
  "username": "+251912345678",
  "code": "123456"
}
Response: {
  "success": true
}
```

#### Reset Password
```
POST /iam/auth/reset-password
Body: {
  "username": "+251912345678",
  "code": "123456",
  "password": "newpassword123"
}
Response: {
  "success": true
}
```

### Task Endpoints

#### Get My Tasks
```
GET /task-distribution/my-tasks
Query Params:
  - page: number
  - limit: number
  - status: "AVAILABLE" | "IN_PROGRESS" | "COMPLETED" (optional, omit for all)

Response: {
  "data": {
    "result": [
      {
        "id": "uuid",
        "name": "Task Name",
        "description": "Task Description",
        "task_type": "text-audio" | "audio-text" | "text-text" | "image-text" | "image-audio",
        "status": "AVAILABLE",
        "require_contributor_test": false,
        "dead_line": "2026-02-01T00:00:00Z",
        "average_time": 30,
        "done_count": 5,
        "total_count": 100,
        "rejected_count": 1,
        "approved_count": 4,
        "pending_count": 0,
        "estimated_earning": 10.50,
        "earning_per_task": 0.50,
        "taskRequirement": {
          "min_seconds": 3,
          "max_seconds": 30
        }
      }
    ]
  }
}
```

**Task Types**:
| API Value | App Enum |
|---|---|
| `text-audio` | `Text_to_Speech` |
| `audio-text` | `Speech_to_Text` |
| `text-text` | `Text_to_Text` |
| `image-text` | `Image_to_Text` |
| `image-audio` | `Image_to_Speech` |

#### Get Task Detail
```
GET /task-distribution/assigned-tasks/:taskId
Response: {
  "data": {
    "id": "uuid",
    "name": "Task Name",
    "task_type": "text-audio",
    "is_test": false,
    "has_passed": "APPROVED" | "PENDING" | "UNDER_REVIEW" | "REJECTED",
    "batch": 1,
    "minimum_seconds": 3,
    "maximum_seconds": 30,
    "minimum_characters_length": 10,
    "maximum_characters_length": 500,
    "contributorMicroTask": [
      {
        "id": "uuid",
        "instruction": "Read this text",
        "file_path": "https://...",
        "text": "Sample text",
        "type": "audio",
        "current_retry": 0,
        "allowed_retry": 3,
        "acceptance_status": "PENDING",
        "can_retry": true,
        "dataSet": { ... }
      }
    ],
    "taskInstruction": {
      "title": "Instruction Title",
      "content": "Detailed instructions...",
      "image_instruction_url": "https://...",
      "video_instruction_url": "https://...",
      "audio_instruction_url": "https://..."
    }
  }
}
```

#### Submit Audio Task
```
POST /task-distribution/:taskId/contribute_audio
Body: FormData {
  "batch": 1,
  "is_test": false,
  "<microTaskId>": File  // one entry per recorded micro-task
}
Headers: {
  "Content-Type": "multipart/form-data"
}
Response: {
  "success": true
}
```

#### Submit Text Task
```
POST /task-distribution/:taskId/contribute
Body: {
  "batch": 1,
  "is_test": false,
  "attempts": [
    {
      "micro_task_id": "uuid",
      "text_data_set": "transcribed text"
    }
  ]
}
Response: {
  "success": true
}
```

#### Get Submission History
```
GET /task-distribution/contributor-micro-task-submissions/:microTaskId
Response: {
  "data": [ ... ]
}
```

### Wallet Endpoints

#### Get Balance
```
GET /wallet/balance
Response: {
  "data": 125.50
}
```

#### Get Withdraw Options (Banks)
```
GET /wallet/get-withdraw-options
Response: {
  "data": [
    {
      "id": 1,
      "slug": "cbe",
      "swift": "CBETETAA",
      "name": "Commercial Bank of Ethiopia",
      "acct_length": 13,
      "is_mobilemoney": false,
      "is_active": true
    }
  ]
}
```

#### Withdraw Money
```
POST /wallet/withdraw-money
Headers: {
  "x-idempotency-key": "<timestamp>-<random>"
}
Body: {
  "account_number": "1234567890123",
  "amount": 100.00,
  "bank_code": "cbe"
}
Response: {
  "success": true
}
```

### Profile Endpoints

#### Get Profile
```
GET /iam/users/me
Response: {
  "data": {
    "id": "uuid",
    "first_name": "John",
    "middle_name": "Doe",
    "last_name": "Smith",
    "email": "john@example.com",
    "phone": "+251912345678",
    "profile_picture": "https://...",
    "gender": "Male",
    "birth_date": "1990-01-01",
    "language": { ... },
    "dialect": { ... }
  }
}
```

#### Update Profile
```
PUT /iam/users/me
Body: {
  "first_name": "John",
  "middle_name": "Doe",
  "last_name": "Smith",
  "email": "john@example.com"
}
Response: {
  "success": true
}
```

#### Upload Profile Picture
```
PUT /iam/users/profile
Body: FormData {
  "image": File
}
Response: {
  "data": {
    "profile_picture": "https://..."
  }
}
```

#### Upload National ID
```
PATCH /iam/users/national_id
Body: FormData {
  "image": File
}
Response: {
  "success": true
}
```

#### Apply Referral Code
```
PATCH /iam/users/referral_code
Body: {
  "referral_code": "ABC123"
}
Response: {
  "success": true
}
```

#### Update Preferred Language
```
PATCH /iam/users/preferred-language
Body: {
  "language_key": "am"
}
Response: {
  "success": true
}
```

#### Change Password
```
PUT /iam/users/change-password
Body: {
  "current_password": "oldpassword",
  "new_password": "newpassword"
}
Response: {
  "success": true
}
```

### Notification Endpoints

#### Get Notifications
```
GET /notifications/me
Query Params:
  - page: number
  - limit: number

Response: {
  "notifications": [
    {
      "id": "uuid",
      "title": "Notification Title",
      "message": "Notification message",
      "type": "task_assigned",
      "isRead": false,
      "createdAt": "2026-01-27T10:00:00Z"
    }
  ],
  "total": 50,
  "unreadCount": 10
}
```

#### Mark as Read
```
PATCH /notifications/:id/read
Response: {
  "success": true
}
```

#### Mark All as Read
```
PATCH /notifications/read-all
Response: {
  "success": true
}
```

#### Get Unread Count
```
GET /notifications/count-new
Response: {
  "data": 10
}
```

### AI Chatbot Endpoints

#### Ask Question
```
POST /v1/ask
Body: {
  "question": "How do I complete a task?",
  "max_sources": 3,
  "min_similarity": 0.1
}
Response: {
  "answer": "To complete a task...",
  "sources": [
    {
      "content": "Source content...",
      "similarity": 0.85,
      "metadata": { ... }
    }
  ],
  "confidence_score": 0.92,
  "processing_time": 1.23
}
```

**Error codes**:
- `400` — Invalid request / bad question format
- `503` — Service unavailable
- `504` — Request timeout

### Base Data Endpoints

#### Get Languages
```
GET /languages
Response: {
  "languages": [
    {
      "id": "uuid",
      "name": "Amharic",
      "code": "am"
    }
  ]
}
```

#### Get Dialects
```
GET /dialects
Query Params:
  - languageId: uuid

Response: {
  "dialects": [
    {
      "id": "uuid",
      "name": "Addis Ababa",
      "languageId": "uuid"
    }
  ]
}
```

## Request/Response Format

### Request Headers

All authenticated requests must include:

```
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

### Response Format

#### Success Response

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

#### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description",
    "details": { ... }
  }
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

## Error Handling

### Error Types

```dart
// Network errors
class NetworkFailure extends Failure {
  NetworkFailure(String message);
}

// Server errors
class ServerFailure extends Failure {
  ServerFailure(String message);
}

// Validation errors
class ValidationFailure extends Failure {
  ValidationFailure(String message);
}

// Authentication errors
class AuthFailure extends Failure {
  AuthFailure(String message);
}
```

### Error Handling Pattern

```dart
try {
  final response = await apiClient.get('/endpoint');
  return Right(response.data);
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    return Left(AuthFailure('Unauthorized'));
  } else if (e.response?.statusCode == 404) {
    return Left(NotFoundFailure('Resource not found'));
  } else {
    return Left(NetworkFailure(e.message ?? 'Network error'));
  }
} catch (e) {
  return Left(UnknownFailure(e.toString()));
}
```

## Interceptors

### Request Interceptor

```dart
// Add authentication token
onRequest: (options, handler) {
  final token = await getAccessToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
}
```

### Response Interceptor

```dart
// Handle token refresh
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    // Refresh token
    final newToken = await refreshAccessToken();

    // Retry request
    final options = error.requestOptions;
    options.headers['Authorization'] = 'Bearer $newToken';
    final response = await dio.fetch(options);

    return handler.resolve(response);
  }
  return handler.next(error);
}
```

## File Upload

### Audio Task Submission

```dart
// Build a FormData map keyed by microTaskId
final Map<String, MultipartFile> recordings = {
  microTaskId: MultipartFile.fromFileSync(filePath),
};
final formData = FormData.fromMap(recordings);
formData.fields.add(MapEntry('batch', batch.toString()));
formData.fields.add(MapEntry('is_test', isTest.toString()));

await apiClient.post(
  '/task-distribution/$taskId/contribute_audio',
  data: formData,
  options: Options(headers: {'Content-Type': 'multipart/form-data'}),
);
```

### Profile Picture Upload

```dart
final formData = FormData.fromMap({
  'image': await MultipartFile.fromFile(imagePath),
});

await apiClient.put('/iam/users/profile', data: formData);
```

## Pagination

### Request

```dart
GET /task-distribution/my-tasks?page=1&limit=10
```

### Response

```json
{
  "data": {
    "result": [ ... ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 100,
      "totalPages": 10,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

## Idempotency

Withdrawal requests require an idempotency key to prevent duplicate submissions:

```
x-idempotency-key: <timestamp>-<random_6_digit_number>
```

## Rate Limiting

The API may implement rate limiting:

- **Limit**: 100 requests per minute per user
- **Headers**:
  - `X-RateLimit-Limit`: Total allowed requests
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Time when limit resets

## Caching Strategy

### Cache-Control Headers

```
Cache-Control: max-age=3600, must-revalidate
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

### Implementation

```dart
// Cache GET requests
final cachedResponse = await cacheManager.get(url);
if (cachedResponse != null && !isExpired(cachedResponse)) {
  return cachedResponse;
}

// Fetch from API
final response = await apiClient.get(url);

// Cache response
await cacheManager.put(url, response);
```

## Testing

### Mock API Responses

```dart
// Mock successful response
when(mockApiClient.get('/task-distribution/my-tasks'))
    .thenAnswer((_) async => Response(
      data: {'data': {'result': []}},
      statusCode: 200,
    ));

// Mock error response
when(mockApiClient.get('/task-distribution/my-tasks'))
    .thenThrow(DioException(
      requestOptions: RequestOptions(path: '/task-distribution/my-tasks'),
      response: Response(
        statusCode: 401,
        requestOptions: RequestOptions(path: '/task-distribution/my-tasks'),
      ),
    ));
```

## Security Considerations

### Best Practices

1. **HTTPS Only**: All API calls over HTTPS
2. **Token Storage**: Store tokens in secure storage
3. **Token Expiry**: Implement automatic token refresh
4. **Input Validation**: Validate all inputs before sending
5. **Error Messages**: Don't expose sensitive information
6. **Rate Limiting**: Respect API rate limits
7. **Timeout**: Set appropriate timeouts
8. **Idempotency**: Use idempotency keys for financial operations

### Token Security

```dart
// Store tokens securely
await secureStorage.write(
  key: 'access_token',
  value: accessToken,
);

// Never log tokens
// ❌ Bad
print('Token: $accessToken');

// ✅ Good
logger.d('Token received');
```

## Troubleshooting

### Common Issues

#### 401 Unauthorized
- Check if token is valid
- Verify token refresh logic
- Ensure Authorization header is set

#### 404 Not Found
- Verify endpoint URL
- Check API base URL configuration
- Ensure resource exists

#### Network Timeout
- Check internet connection
- Increase timeout duration
- Implement retry logic

#### 422 Validation Error
- Check request body format
- Verify required fields
- Validate data types

#### Chatbot 503/504
- 503 means the AI service is temporarily down
- 504 means the question took too long to process — retry

## Additional Resources

- [API Constants](lib/core/api/api_constants.dart)
- [API Client](lib/core/api/api_client.dart)
- [API Interceptor](lib/core/api/api_interceptor.dart)
- [Environment Setup](ENVIRONMENT_SETUP.md)

## Support

For API-related issues:
1. Check this documentation
2. Review error logs
3. Test with API client (Postman, Insomnia)
4. Contact backend team

---

**Last Updated**: May 8, 2026
