# Cloud Storage Application API Documentation

This documentation provides details about the available APIs in the Cloud Storage application. The APIs are organized into four main categories: Authentication, File Management, Collection Management, and Trash/Restore Management.

## Base URL

All endpoints are relative to the base URL of your API server.

```
http://localhost:5000/api
```

## Authentication

All API endpoints (except for registration, login, verify-email, forgot-password, and reset-password) require authentication. To authenticate requests, include a Bearer token in the Authorization header.

Example:
```
Authorization: Bearer <access_token>
```

### Register a new user

```
POST /auth/register
```

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response (201 Created):**
```json
{
  "message": "Registration successful. Please check your email to verify your account."
}
```

**Possible Errors:**
- 400 Bad Request: Invalid email or password format
- 409 Conflict: Email already exists

### Verify Email

```
POST /auth/verify-email
```

Verify a user's email address using the token sent to their email.

**Request Body:**
```json
{
  "token": "verification-token-from-email"
}
```

**Response (200 OK):**
```json
{
  "message": "Email verified successfully"
}
```

**Possible Errors:**
- 400 Bad Request: Invalid or expired token

### Verify Email Link

```
GET /auth/verify-email-link?token={token}
```

Alternative endpoint to verify a user's email address via a direct link.

**Parameters:**
- `token` (query string): The verification token from the email

**Response (200 OK):**
```json
{
  "message": "Email verified successfully"
}
```

**Possible Errors:**
- 400 Bad Request: Invalid or expired token

### Login

```
POST /auth/login
```

Authenticate a user and receive an access token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response (200 OK):**
```json
{
  "message": "Login successful",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-id",
    "email": "user@example.com"
  }
}
```

**Possible Errors:**
- 400 Bad Request: Invalid input
- 401 Unauthorized: Invalid credentials or account not verified

### Forgot Password

```
POST /auth/forgot-password
```

Request a password reset link.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset instructions sent to your email"
}
```

**Possible Errors:**
- 400 Bad Request: Invalid input
- 404 Not Found: User not found

### Reset Password

```
POST /auth/reset-password
```

Reset a user's password using the token from the email.

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "new_password": "NewPassword123"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset successfully"
}
```

**Possible Errors:**
- 400 Bad Request: Invalid input or token
- 404 Not Found: User not found

### Get User Information

```
GET /auth/user
```

Get the currently authenticated user's information.

**Response (200 OK):**
```json
{
  "id": "user-id",
  "email": "user@example.com"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: User not found

## File Management

### Upload Files

```
POST /files/upload
```

Upload one or multiple files.

**Request:**
- Content-Type: multipart/form-data
- Form fields:
  - `file`: File(s) to upload (can be multiple)
  - `description` (optional): Description of the file(s)

**Response (200 OK):**
```json
{
  "message": "Files uploaded successfully",
  "files": [
    {
      "id": "file-id-1",
      "filename": "example.jpg",
      "file_type": "image",
      "file_size": 1024,
      "upload_date": "2023-01-01T12:00:00",
      "description": "Example image",
      "download_url": "/api/files/download/file-id-1"
    }
  ]
}
```

**Possible Errors:**
- 400 Bad Request: Invalid file or file type
- 401 Unauthorized: Not authenticated

### Download File

```
GET /files/download/{file_id}
```

Download a specific file by ID.

**Response:**
- The file content with appropriate Content-Type header

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: File not found

### List Files

```
GET /files/files
```

Get a list of all files uploaded by the authenticated user.

**Response (200 OK):**
```json
{
  "files": [
    {
      "id": "file-id-1",
      "filename": "example.jpg",
      "file_type": "image",
      "file_size": 1024,
      "upload_date": "2023-01-01T12:00:00",
      "description": "Example image",
      "download_url": "/api/files/download/file-id-1"
    },
    {
      "id": "file-id-2",
      "filename": "document.pdf",
      "file_type": "document",
      "file_size": 2048,
      "upload_date": "2023-01-02T12:00:00",
      "description": "Example document",
      "download_url": "/api/files/download/file-id-2"
    }
  ]
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated

### Get File Details

```
GET /files/files/{file_id}
```

Get details about a specific file.

**Response (200 OK):**
```json
{
  "id": "file-id-1",
  "filename": "example.jpg",
  "file_type": "image",
  "file_size": 1024,
  "upload_date": "2023-01-01T12:00:00",
  "description": "Example image",
  "download_url": "/api/files/download/file-id-1"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: File not found

### Delete File (Move to Trash)

```
DELETE /files/files/{file_id}
```

Move a specific file to trash.

**Response (200 OK):**
```json
{
  "message": "File moved to trash"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: File not found

### Add File to Collection

```
POST /files/files/{file_id}/add-to-collection
```

Add a file to a collection.

**Request Body:**
```json
{
  "collection_id": "collection-id"
}
```

**Response (200 OK):**
```json
{
  "message": "File added to collection successfully"
}
```

**Possible Errors:**
- 400 Bad Request: Invalid input
- 401 Unauthorized: Not authenticated
- 404 Not Found: File or collection not found

### Remove File from Collection

```
DELETE /files/files/{file_id}/remove-from-collection/{collection_id}
```

Remove a file from a collection.

**Response (200 OK):**
```json
{
  "message": "File removed from collection successfully"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: File or collection not found

## Collection Management

### List Collections

```
GET /collections
```

Get a list of all collections created by the authenticated user.

**Response (200 OK):**
```json
{
  "collections": [
    {
      "id": "collection-id-1",
      "name": "My Images",
      "owner_id": "user-id",
      "created_at": "2023-01-01T12:00:00",
      "updated_at": "2023-01-01T12:00:00"
    },
    {
      "id": "collection-id-2",
      "name": "Documents",
      "owner_id": "user-id",
      "created_at": "2023-01-02T12:00:00",
      "updated_at": "2023-01-02T12:00:00"
    }
  ]
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated

### Create Collection

```
POST /collections
```

Create a new collection.

**Request Body:**
```json
{
  "name": "My New Collection"
}
```

**Response (201 Created):**
```json
{
  "message": "Collection created successfully",
  "collection": {
    "id": "new-collection-id",
    "name": "My New Collection",
    "owner_id": "user-id",
    "created_at": "2023-01-03T12:00:00",
    "updated_at": "2023-01-03T12:00:00"
  }
}
```

**Possible Errors:**
- 400 Bad Request: Invalid input
- 401 Unauthorized: Not authenticated

### Get Collection Details

```
GET /collections/{collection_id}
```

Get details about a specific collection.

**Response (200 OK):**
```json
{
  "id": "collection-id-1",
  "name": "My Images",
  "owner_id": "user-id",
  "created_at": "2023-01-01T12:00:00",
  "updated_at": "2023-01-01T12:00:00"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: Collection not found

### Update Collection

```
PUT /collections/{collection_id}
```

Update a collection's details.

**Request Body:**
```json
{
  "name": "Updated Collection Name"
}
```

**Response (200 OK):**
```json
{
  "message": "Collection updated successfully",
  "collection": {
    "id": "collection-id-1",
    "name": "Updated Collection Name",
    "owner_id": "user-id",
    "created_at": "2023-01-01T12:00:00",
    "updated_at": "2023-01-03T12:00:00"
  }
}
```

**Possible Errors:**
- 400 Bad Request: Invalid input
- 401 Unauthorized: Not authenticated
- 404 Not Found: Collection not found

### Delete Collection (Move to Trash)

```
DELETE /collections/{collection_id}
```

Move a specific collection to trash.

**Response (200 OK):**
```json
{
  "message": "Collection moved to trash"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: Collection not found

### Get Files in Collection

```
GET /collections/{collection_id}/files
```

Get all files in a specific collection.

**Response (200 OK):**
```json
{
  "collection_id": "collection-id-1",
  "collection_name": "My Images",
  "files": [
    {
      "id": "file-id-1",
      "filename": "example.jpg",
      "file_type": "image",
      "file_size": 1024,
      "upload_date": "2023-01-01T12:00:00",
      "description": "Example image",
      "download_url": "/api/files/download/file-id-1"
    }
  ]
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: Collection not found

## Trash and Restore Management

### List Trash Items

You can access trash items through any of the following endpoints:

```
GET /api/trash
GET /api/files/trash
GET /api/restore/trash
GET /trash  (Redirects to /api/trash)
```

Get a list of all items in the trash for the authenticated user.

**Response (200 OK):**
```json
[
  {
    "id": "trash-file-id-1",
    "name": "example.jpg",
    "type": "file",
    "deleted_at": "2023-01-10T12:00:00",
    "original_path": "/path/to/file/example.jpg",
    "size": 1024
  },
  {
    "id": "trash-collection-id-1",
    "name": "My Collection",
    "type": "collection",
    "deleted_at": "2023-01-10T12:00:00"
  }
]
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated

### Restore File

```
POST /api/restore/file/{file_id}
POST /api/trash/file/{file_id}
```

Restore a file from trash.

**Response (200 OK):**
```json
{
  "message": "File restored successfully"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: File not found in trash

### Restore Collection

```
POST /api/restore/collection/{collection_id}
POST /api/trash/collection/{collection_id}
```

Restore a collection from trash.

**Response (200 OK):**
```json
{
  "message": "Collection restored successfully"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: Collection not found in trash

### Permanently Delete Item

```
DELETE /api/trash/{item_id}
DELETE /api/restore/{item_id}
```

Permanently delete an item from trash.

**Response (200 OK):**
```json
{
  "message": "Item deleted permanently"
}
```

**Possible Errors:**
- 401 Unauthorized: Not authenticated
- 404 Not Found: Item not found in trash
