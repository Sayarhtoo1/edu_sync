# Project Analysis: EduSync School Management App

## 1. Overview

This document provides a comprehensive analysis of the existing EduSync Flutter project. The application is a school management system that utilizes Flutter for the frontend and Supabase for the backend. The analysis covers the project structure, database schema, core features, and user roles.

## 2. Project Structure

The Flutter project is well-organized, following a feature-driven architecture. The `lib` directory is structured as follows:

- **`config`**: Contains configuration files for providers and routing.
- **`database`**: Manages the local Drift database for offline caching.
- **`l10n`**: Handles localization and internationalization.
- **`models`**: Defines the data models used throughout the application.
- **`providers`**: Manages the application's state using the Provider package.
- **`screens`**: Contains the UI for different user roles (admin, teacher, parent).
- **`services`**: Implements the business logic and handles communication with the Supabase backend.
- **`theme`**: Defines the application's visual theme.
- **`utils`**: Includes utility functions and helper classes.
- **`widgets`**: Contains reusable UI components.

## 3. Database Schema

The application's data is stored in a Supabase PostgreSQL database. The schema is well-defined and includes the following tables:

- **`users`**: Stores user profile information, linked to Supabase Auth.
- **`schools`**: Contains details about each school.
- **`classes`**: Manages classes within a school.
- **`students`**: Stores student information.
- **`parent_student_relations`**: Links parents to their children.
- **`attendance`**: Records student attendance.
- **`lesson_plans`**: Stores lesson plans created by teachers.
- **`timetables`**: Manages class schedules.
- **`finance_entries`**: Tracks income and expenses.
- **`user_settings`**: Stores user-specific application settings.
- **`announcements`**: Manages school-wide announcements.

Row Level Security (RLS) is enabled on all tables to ensure data privacy and security.

## 4. Core Features

The application implements a wide range of features for different user roles:

### Admin Features:
- **User Management**: Admins can create, edit, and delete users (teachers, parents).
- **Class Management**: Admins can manage classes and assign teachers.
- **Student Management**: Admins can add, edit, and delete student profiles.
- **Finance Management**: Admins can track income and expenses.
- **Timetable Management**: Admins can create and manage class timetables.
- **Announcements**: Admins can create and send announcements to different user groups.
- **Custom Forms**: Admins can create and manage custom forms for data collection.

### Teacher Features:
- **Dashboard**: Teachers have a personalized dashboard with a summary of their daily schedule.
- **Timetable**: Teachers can view their class schedules.
- **Attendance**: Teachers can mark and view student attendance.
- **Lesson Plans**: Teachers can create and manage lesson plans.

### Parent Features:
- **Dashboard**: Parents have a dashboard to view their children's information.
- **Attendance**: Parents can view their children's attendance records.
- **Announcements**: Parents receive school-wide and class-specific announcements.

## 5. User Roles

The application supports three main user roles:

- **Admin**: Manages the entire school, including users, classes, finances, and announcements.
- **Teacher**: Manages their classes, marks attendance, and creates lesson plans.
- **Parent**: Views their children's progress, attendance, and receives announcements.

## 6. Conclusion

The EduSync application is a robust and feature-rich school management system with a solid foundation. The project is well-structured, and the database schema is designed to support a wide range of school management functionalities. The existing features provide a strong starting point for further development and the addition of new capabilities.