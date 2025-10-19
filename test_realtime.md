# Test Supabase Realtime Connection

## Quick Test in Browser Console

Open your browser console and run:

```javascript
// Test if Realtime is working
const { createClient } = supabase
const supabaseUrl = 'https://rcrhktgfkgkwuosyclbo.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjcmhrdGdma2drd3Vvc3ljbGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NTMxNzIsImV4cCI6MjA2MjMyOTE3Mn0.mTD6GqRA650VinZzo5AIHLRbWUxor5GuvSjKMGtq5II'

const client = createClient(supabaseUrl, supabaseKey)

// Subscribe to announcements
const channel = client
  .channel('test-announcements')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'announcements' },
    (payload) => {
      console.log('✅ Realtime working! New announcement:', payload)
    }
  )
  .subscribe((status) => {
    console.log('Subscription status:', status)
  })

// Now create an announcement and see if you get the console log
```

## Enable Realtime in Supabase Dashboard

1. Go to: https://supabase.com/dashboard/project/rcrhktgfkgkwuosyclbo/database/replication
2. Find `announcements` table
3. Toggle ON the Realtime switch
4. Save changes

## SQL Script to Enable Realtime

Run this in Supabase SQL Editor:

```sql
-- Enable Realtime for announcements table
ALTER PUBLICATION supabase_realtime ADD TABLE announcements;

-- Verify
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';
```

## Check if it's already enabled

```sql
-- Check current Realtime tables
SELECT * FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';
```

If `announcements` is not in the list, you need to enable it!
