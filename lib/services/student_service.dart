import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/database/app_database.dart' as db; // Alias AppDatabase
import 'api_service.dart';

class StudentService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final db.AppDatabase _appDatabase; // Add AppDatabase instance
  final ApiService _apiService = ApiService();
  // final ClassService _classService; // ClassService now requires AppDatabase - Removed as it's unused

  StudentService(this._appDatabase); // Initialize AppDatabase

  // Fetch all students for a school using the new view
  Future<List<Student>> getStudentsBySchool(int schoolId, {int? classId}) async {
    try {
      var query = _supabaseClient
          .from('school_students_view')
          .select()
          .eq('school_id', schoolId);

      if (classId != null) {
        query = query.eq('class_id', classId);
      }

      final response = await query.order('full_name', ascending: true);
      final students = response.map((data) => Student.fromMap(data)).toList();
      return students;
    } catch (e) {
      logger.e('Error fetching students by school: $e');
      return [];
    }
  }

  // Fetch students for a specific class
  Future<List<Student>> getStudentsByClass(int classId) async { // Corrected to int
    // TODO: Implement drift caching for students
    return await _apiService.fetchData<List<Student>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('students')
            .select()
            .eq('class_id', classId);
        return response.map((data) => Student.fromMap(data)).toList();
      },
      offlineRequest: () async {
        // For now, no offline support for students by class in drift
        return [];
      },
      cacheData: (data) async {
        // For now, no caching for students by class in drift
      },
    );
  }
  
  // Creates a student without linking a parent.
  Future<int?> createStudent({
    required String studentName,
    required int schoolId,
    int? classId,
    DateTime? dateOfBirth,
    String? profilePhotoUrl,
    String? gender,
    String? phoneNumber1,
    String? phoneNumber2,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'full_name': studentName,
        'school_id': schoolId,
      };
      
      if (classId != null) data['class_id'] = classId;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toIso8601String();
      if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) data['profile_photo_url'] = profilePhotoUrl;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (phoneNumber1 != null && phoneNumber1.isNotEmpty) data['phone_number_1'] = phoneNumber1;
      if (phoneNumber2 != null && phoneNumber2.isNotEmpty) data['phone_number_2'] = phoneNumber2;
      
      logger.i('Creating student with data: $data');
      
      final response = await _supabaseClient.from('students').insert(data).select('id').single();
      return response['id'] as int?;
    } catch (e) {
      logger.e('Error creating student: $e');
      return null;
    }
  }

  // Creates a student and links them to a parent in a single transaction.
  Future<int?> createStudentWithParent({
    required String studentName,
    required int schoolId,
    int? classId,
    required String parentId,
    required String relationType,
    DateTime? dateOfBirth,
    String? profilePhotoUrl,
    String? gender,
    String? phoneNumber1,
    String? phoneNumber2,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'p_student_name': studentName,
        'p_school_id': schoolId,
        'p_parent_id': parentId,
        'p_relation_type': relationType,
      };
      
      if (classId != null) params['p_class_id'] = classId;
      if (dateOfBirth != null) params['p_date_of_birth'] = dateOfBirth.toIso8601String();
      if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) params['p_profile_photo_url'] = profilePhotoUrl;
      if (gender != null && gender.isNotEmpty) params['p_gender'] = gender;
      if (phoneNumber1 != null && phoneNumber1.isNotEmpty) params['p_phone_number_1'] = phoneNumber1;
      if (phoneNumber2 != null && phoneNumber2.isNotEmpty) params['p_phone_number_2'] = phoneNumber2;
      
      logger.i('Creating student with parent, params: $params');
      
      final newStudentId = await _supabaseClient.rpc(
        'create_student_and_link_parent',
        params: params,
      );
      return newStudentId as int?;
    } catch (e) {
      logger.e('Error creating student with parent link via RPC: $e');
      return null;
    }
  }

  // Update student details
  Future<bool> updateStudent(Student student) async {
    try {
      await _supabaseClient
          .from('students')
          .update(student.toMap()..remove('id')) // Do not update id
          .eq('id', student.id);
      return true;
    } catch (e) {
      logger.e('Error updating student: $e');
      return false;
    }
  }

  // Delete a student
  Future<bool> deleteStudent(int studentId) async {
    try {
      await _supabaseClient
          .from('students')
          .delete()
          .eq('id', studentId);
      return true;
    } catch (e) {
      logger.e('Error deleting student: $e');
      return false;
    }
  }

  // Upload student profile photo
  Future<String?> uploadStudentProfilePhoto(int studentId, String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final storagePath = 'students/profile_photos/$studentId/$fileName';
      await _supabaseClient.storage
          .from('edusync') // Bucket name
          .upload(storagePath, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
      
      final publicUrl = _supabaseClient.storage.from('edusync').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      logger.e('Error uploading student profile photo: $e');
    }
    return null;
  }

  // Unlink a parent from a student
  Future<bool> unlinkParentFromStudent(String parentId, int studentId) async {
    try {
      await _supabaseClient
          .from('parent_student_relations')
          .delete()
          .eq('parent_id', parentId)
          .eq('student_id', studentId);
      return true;
    } catch (e) {
      logger.e('Error unlinking parent from student: $e');
      return false;
    }
  }

  // Get student IDs for a parent
  Future<List<int>> getStudentIdsForParent(String parentId) async {
    // TODO: Implement drift caching for student IDs for parent
    return await _apiService.fetchData<List<int>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('parent_student_relations')
            .select('student_id')
            .eq('parent_id', parentId);
        return response.map((data) => data['student_id'] as int).toList();
      },
      offlineRequest: () async {
        // For now, no offline support for student IDs for parent in drift
        return [];
      },
      cacheData: (data) async {
        // For now, no caching for student IDs for parent in drift
      },
    );
  }

  // Fetch full student details for a parent
  Future<List<Student>> getStudentsByParent(String parentId, int schoolId) async {
    // TODO: Implement drift caching for students by parent
    return await _apiService.fetchData<List<Student>>(
      onlineRequest: () async {
        final studentIds = await getStudentIdsForParent(parentId);
        if (studentIds.isEmpty) {
          return [];
        }
        final response = await _supabaseClient
            .from('students')
            .select()
            .filter('id', 'in', studentIds)
            .eq('school_id', schoolId);
        return response.map((data) => Student.fromMap(data)).toList();
      },
      offlineRequest: () async {
        // For now, no offline support for students by parent in drift
        return [];
      },
      cacheData: (data) async {
        // For now, no caching for students by parent in drift
      },
    );
  }

  // Get parent IDs for a student
  Future<List<String>> getParentIdsForStudent(int studentId) async {
    // TODO: Implement drift caching for parent IDs for student
    return await _apiService.fetchData<List<String>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('parent_student_relations')
            .select('parent_id')
            .eq('student_id', studentId);
        return response.map((data) => data['parent_id'] as String).toList();
      },
      offlineRequest: () async {
        // For now, no offline support for parent IDs for student in drift
        return [];
      },
      cacheData: (data) async {
        // For now, no caching for parent IDs for student in drift
      },
    );
  }

  Future<Student?> getStudentById(int studentId, int schoolId) async {
    // TODO: Implement drift caching for student by ID
    return await _apiService.fetchData<Student?>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('students')
            .select()
            .eq('id', studentId)
            .eq('school_id', schoolId)
            .single();
        return Student.fromMap(response);
      },
      offlineRequest: () async {
        // For now, no offline support for student by ID in drift
        return null;
      },
      cacheData: (data) async {
        // For now, no caching for student by ID in drift
      },
    );
  }
}
