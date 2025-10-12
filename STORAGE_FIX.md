# Storage and Photo Upload Fix

## Problem
Profile photos were not being saved because:
1. **No storage policies existed** - Users couldn't upload files to Supabase Storage
2. Photo URLs were not being saved to the database

## Solution

### 1. Created Storage Policies ✅
Added four policies to the `storage.objects` table:

- **Authenticated users can upload to edusync** (INSERT)
  - Allows any authenticated user to upload files to the edusync bucket
  
- **Authenticated users can update in edusync** (UPDATE)
  - Allows authenticated users to update/replace files
  
- **Authenticated users can delete from edusync** (DELETE)
  - Allows authenticated users to delete files
  
- **Anyone can read from edusync** (SELECT)
  - Allows public read access to all files (since bucket is public)

### 2. Storage Configuration
- **Bucket**: `edusync` (already existed)
- **Public**: Yes
- **File paths**:
  - Staff/Users: `users/profile_photos/{userId}/{filename}`
  - Students: `students/profile_photos/{studentId}/{filename}`

### 3. Upload Flow

#### For Staff (Create):
1. Create user via Edge Function
2. Upload photo to storage using user ID
3. Update user record with photo URL

#### For Staff (Edit):
1. Upload photo to storage using existing user ID
2. Update user record with new photo URL

#### For Students (Create):
1. Create student record
2. Upload photo to storage using student ID
3. Update student record with photo URL

#### For Students (Edit):
1. Upload photo to storage using existing student ID
2. Update student record with new photo URL

## Testing

To test if photos are now working:

1. **Create a new staff member with a photo**
   - Go to Admin → Staff Management → Add Staff
   - Fill in details and select a photo
   - Save and verify photo appears

2. **Edit existing staff and add/change photo**
   - Go to Admin → Staff Management
   - Click edit on a staff member
   - Change or add photo
   - Save and verify photo updates

3. **Create a new student with a photo**
   - Go to Admin → Student Management → Add Student
   - Fill in details and select a photo
   - Save and verify photo appears

4. **Edit existing student and add/change photo**
   - Go to Admin → Student Management
   - Click edit on a student
   - Change or add photo
   - Save and verify photo updates

## Verification Query

To check if photos are being saved:

```sql
SELECT id, full_name, profile_photo_url, role 
FROM users 
WHERE profile_photo_url IS NOT NULL;
```

```sql
SELECT id, full_name, profile_photo_url 
FROM students 
WHERE profile_photo_url IS NOT NULL;
```

## Notes

- Photos are stored in Supabase Storage bucket `edusync`
- Public URLs are generated and saved to the database
- The `upsert: true` option allows replacing existing photos
- Cache control is set to 3600 seconds (1 hour)
