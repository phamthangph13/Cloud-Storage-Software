### Rename File

```
PUT /files/files/{file_id}
```

Rename a specific file.

**Request Body:**
```json
{
  "new_filename": "new_file_name.jpg"
}
```

**Response (200 OK):**
```json
{
  "message": "File renamed successfully",
  "file": {
    "id": "file-id-1",
    "filename": "new_file_name.jpg",
    "file_type": "image",
    "file_size": 1024,
    "upload_date": "2023-01-01T12:00:00",
    "description": "Example image",
    "download_url": "/api/files/download/file-id-1"
  }
}
```

**Possible Errors:**
- 400 Bad Request: Invalid filename
- 401 Unauthorized: Not authenticated
- 403 Forbidden: Permission denied
- 404 Not Found: File not found