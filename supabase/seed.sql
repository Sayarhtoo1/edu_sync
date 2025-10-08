-- Seed data for EduSync application
-- This file contains initial data for testing and development

-- Insert sample schools
INSERT INTO public.schools (name, logo_url, academic_year, theme, contact_info) VALUES
('Springfield Elementary School', 'https://example.com/logo1.png', '2024-2025', 'blue-green', 'contact@springfield.edu'),
('Riverside High School', 'https://example.com/logo2.png', '2024-2025', 'green-orange', 'contact@riverside.edu'),
('Lincoln Middle School', 'https://example.com/logo3.png', '2024-2025', 'purple-blue', 'contact@lincoln.edu')
ON CONFLICT (id) DO NOTHING;

-- Insert sample grades configuration
INSERT INTO public.grades (school_id, grade_name, min_percentage, max_percentage, remarks) VALUES
(1, 'A+', 90, 100, 'Excellent performance'),
(1, 'A', 80, 89, 'Very good performance'),
(1, 'B+', 70, 79, 'Good performance'),
(1, 'B', 60, 69, 'Satisfactory performance'),
(1, 'C+', 50, 59, 'Average performance'),
(1, 'C', 40, 49, 'Below average performance'),
(1, 'F', 0, 39, 'Needs improvement'),
(2, 'A+', 90, 100, 'Excellent performance'),
(2, 'A', 80, 89, 'Very good performance'),
(2, 'B+', 70, 79, 'Good performance'),
(2, 'B', 60, 69, 'Satisfactory performance'),
(2, 'C+', 50, 59, 'Average performance'),
(2, 'C', 40, 49, 'Below average performance'),
(2, 'F', 0, 39, 'Needs improvement'),
(3, 'A+', 90, 100, 'Excellent performance'),
(3, 'A', 80, 89, 'Very good performance'),
(3, 'B+', 70, 79, 'Good performance'),
(3, 'B', 60, 69, 'Satisfactory performance'),
(3, 'C+', 50, 59, 'Average performance'),
(3, 'C', 40, 49, 'Below average performance'),
(3, 'F', 0, 39, 'Needs improvement')
ON CONFLICT (id) DO NOTHING;

-- Insert sample subjects for different classes
INSERT INTO public.subjects (school_id, name, code, class_id) VALUES
-- School 1 subjects
(1, 'Mathematics', 'MATH101', NULL),
(1, 'English Language', 'ENG101', NULL),
(1, 'Science', 'SCI101', NULL),
(1, 'Social Studies', 'SOC101', NULL),
(1, 'Art', 'ART101', NULL),
(1, 'Physical Education', 'PE101', NULL),
-- School 2 subjects
(2, 'Advanced Mathematics', 'MATH201', NULL),
(2, 'Literature', 'LIT201', NULL),
(2, 'Physics', 'PHY201', NULL),
(2, 'Chemistry', 'CHEM201', NULL),
(2, 'Biology', 'BIO201', NULL),
(2, 'History', 'HIST201', NULL),
-- School 3 subjects
(3, 'Basic Mathematics', 'MATH301', NULL),
(3, 'Grammar', 'GRAM301', NULL),
(3, 'General Science', 'GENSCI301', NULL),
(3, 'Geography', 'GEO301', NULL),
(3, 'Music', 'MUSIC301', NULL),
(3, 'Computer Studies', 'COMP301', NULL)
ON CONFLICT (id) DO NOTHING;

-- Insert sample school settings
INSERT INTO public.school_settings (school_id, location_latitude, location_longitude, attendance_radius_meters, official_start_time, official_end_time) VALUES
(1, 40.7128, -74.0060, 100, '08:00:00', '15:00:00'),
(2, 34.0522, -118.2437, 150, '07:30:00', '14:30:00'),
(3, 41.8781, -87.6298, 120, '08:30:00', '15:30:00')
ON CONFLICT (school_id) DO NOTHING;

-- Note: User accounts, classes, students, and other dynamic data should be created through the application
-- This seed file provides the basic reference data needed for the application to function