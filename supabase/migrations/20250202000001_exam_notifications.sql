-- Create exam_notifications table
CREATE TABLE IF NOT EXISTS exam_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  notification_type TEXT NOT NULL CHECK (notification_type IN ('exam_reminder', 'result_published', 'marks_deadline')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE,
  target_roles TEXT[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_exam_notifications_exam_id ON exam_notifications(exam_id);
CREATE INDEX idx_exam_notifications_scheduled_at ON exam_notifications(scheduled_at);
CREATE INDEX idx_exam_notifications_sent_at ON exam_notifications(sent_at);

-- Create notification preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  exam_reminders BOOLEAN DEFAULT TRUE,
  result_notifications BOOLEAN DEFAULT TRUE,
  marks_deadline_alerts BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Create index
CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);
