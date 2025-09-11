const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://rcrhktgfkgkwuosyclbo.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjcmhrdGdma2drd3Vvc3ljbGJvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0Njc1MzE3MiwiZXhwIjoyMDYyMzI5MTcyfQ.rKYvhgaHgOnm-9ZCCo-d9CsTQEWyy2dOFw3IVVuMxW0';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function createTestUser() {
  try {
    const { data, error } = await supabase.auth.admin.createUser({
      email: 'teacher_test_new@example.com',
      password: 'password123',
      user_metadata: {
        role: 'Teacher',
        full_name: 'Test Teacher New',
        school_id: 1
      },
      email_confirm: true // Auto-confirm email for testing
    });

    if (error) {
      console.error('Error creating user:', error);
    } else {
      console.log('User created successfully:', data.user);
      // Verify the user in public.users table
      const { data: publicUserData, error: publicUserError } = await supabase
        .from('users')
        .select('*')
        .eq('id', data.user.id)
        .single();

      if (publicUserError) {
        console.error('Error fetching public user data:', publicUserError);
      } else {
        console.log('Public user data:', publicUserData);
      }
    }
  } catch (err) {
    console.error('An unexpected error occurred:', err);
  }
}

createTestUser();
