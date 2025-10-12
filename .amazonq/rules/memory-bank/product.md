# Product Overview

## Project Purpose
EduSync Myanmar is a comprehensive school management system built with Flutter, designed to streamline educational administration for schools in Myanmar. The platform provides a unified solution for managing students, teachers, staff, parents, and administrative operations with bilingual support (English and Myanmar).

## Value Proposition
- **Multi-role Management**: Supports Admin, Teacher, Parent, Manager, Donator, and Student roles with role-specific dashboards and features
- **Comprehensive School Operations**: Handles attendance, timetables, exams, grades, announcements, lesson plans, and custom forms
- **Financial Management**: Complete finance module including fee structures, donations, salary payments, income, and expense tracking
- **Exam System**: Full-featured exam management with marks entry, analytics, report cards, templates, and approval workflows
- **Offline-First Architecture**: Uses Drift (SQLite) for local caching with Supabase backend synchronization
- **Bilingual Support**: Native Myanmar language support with localization infrastructure

## Key Features

### Administrative Features
- User and role management with Supabase authentication
- School profile and settings management
- Staff and student management with comprehensive profiles
- Class and timetable management
- Custom form builder with response tracking
- Announcement system for school-wide communications
- Analytics dashboard with performance insights
- Finance overview with income/expense tracking

### Exam Management
- Exam creation and scheduling with calendar view
- Subject and grade management
- Marks entry and approval workflows
- Report card generation (PDF export)
- Exam analytics and performance tracking
- Exam templates for recurring assessments
- Notification preferences for exam events

### Teacher Features
- Modern teacher dashboard with class overview
- Attendance marking for students
- Lesson plan management
- Student management and performance tracking
- Marks input for exams
- Timetable viewing

### Parent Features
- Child attendance monitoring
- Child schedule and timetable viewing
- Exam schedule and report card access
- Announcements and daily reports
- Student performance tracking

### Financial Features
- Fee structure management with payment tracking
- Donation management for donors
- Salary payment processing for staff
- Income and expense categorization
- Financial overview and reporting

## Target Users

### Primary Users
- **School Administrators**: Complete control over school operations, user management, and system configuration
- **Teachers**: Daily classroom management, attendance, lesson planning, and marks entry
- **Parents**: Monitor children's academic progress, attendance, and school communications
- **Students**: Access personal academic records, schedules, and performance data

### Secondary Users
- **School Managers**: Financial oversight and operational analytics
- **Donators**: Track donations and view school financial transparency
- **Staff Members**: Access personal profiles and attendance records

## Use Cases

### Daily Operations
- Mark student attendance across multiple classes
- View and manage daily timetables
- Post and read school announcements
- Track staff attendance and status

### Academic Management
- Create and schedule exams across grades
- Enter and approve student marks
- Generate report cards for distribution
- Analyze student performance trends
- Manage lesson plans and curriculum

### Financial Operations
- Process fee payments from parents
- Record donations from supporters
- Manage staff salary payments
- Track school income and expenses
- Generate financial reports

### Communication
- Broadcast announcements to specific roles
- Send exam notifications to parents
- Share daily reports with parents
- Distribute custom forms for data collection

## Technical Highlights
- **Cross-Platform**: Runs on Android, iOS, Windows, Linux, macOS, and Web
- **Real-time Sync**: Supabase backend with real-time data synchronization
- **Offline Support**: Local database with automatic sync when online
- **Modern UI**: Material Design 3 with custom theming
- **Scalable Architecture**: Provider pattern with service layer separation
- **Type-Safe**: Comprehensive data models with null safety
