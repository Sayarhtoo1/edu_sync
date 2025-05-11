import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/student.dart';

class StudentService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Fetch all students for a school
  Future<List<Student>> getStudentsBySchool(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select()
          .eq('school_id', schoolId);
      return response.map((data) => Student.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching students by school: $e');
      return [];
    }
  }

  // Fetch students for a specific class
  Future<List<Student>> getStudentsByClass(int classId) async { // Corrected to int
    try {
      final response = await _supabaseClient
          .from('students')
          .select()
          .eq('class_id', classId);
      return response.map((data) => Student.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching students by class: $e');
      return [];
    }
  }
  
  // Add a new student
  Future<Student?> createStudent(Student student) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .insert(student.toMap()..remove('id')) // Remove id for insert
          .select()
          .single();
      return Student.fromMap(response);
    } catch (e) {
      print('Error creating student: $e');
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
      print('Error updating student: $e');
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
      print('Error deleting student: $e');
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
      print('Error uploading student profile photo: $e');
    }
    return null;
  }

  // Link a parent to a student
  Future<bool> linkParentToStudent(String parentId, int studentId, String relationType) async {
    try {
      await _supabaseClient.from('parent_student_relations').insert({
        'parent_id': parentId,
        'student_id': studentId,
        'relation_type': relationType,
      });
      return true;
    } catch (e) {
      print('Error linking parent to student: $e');
      return false;
    }
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
      print('Error unlinking parent from student: $e');
      return false;
    }
  }

  // Get student IDs for a parent
  Future<List<int>> getStudentIdsForParent(String parentId) async {
    try {
      final response = await _supabaseClient
          .from('parent_student_relations')
          .select('student_id')
          .eq('parent_id', parentId);
      return response.map((data) => data['student_id'] as int).toList();
    } catch (e) {
      print('Error fetching student IDs for parent: $e');
      return [];
    }
  }

  // Fetch full student details for a parent
  Future<List<Student>> getStudentsByParent(String parentId, int schoolId) async {
    try {
      final studentIds = await getStudentIdsForParent(parentId);
      if (studentIds.isEmpty) {
        return [];
      }
      // Fetch students whose IDs are in the list and belong to the specified school
      // This also respects RLS on the students table (e.g., parent can only see their linked students)
      final response = await _supabaseClient
          .from('students')
          .select()
          .filter('id', 'in', studentIds) // Corrected 'in' filter
          .eq('school_id', schoolId); // Ensure students are from the correct school context
          
      return response.map((data) => Student.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching students for parent $parentId: $e');
      return [];
    }
  }

  // Get parent IDs for a student
  Future<List<String>> getParentIdsForStudent(int studentId) async {
    try {
      final response = await _supabaseClient
          .from('parent_student_relations')
          .select('parent_id')
          .eq('student_id', studentId);
      return response.map((data) => data['parent_id'] as String).toList();
    } catch (e) {
      print('Error fetching parent IDs for student $studentId: $e');
      return [];
    }
  }

  Future<Student?> getStudentById(int studentId, int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select()
          .eq('id', studentId)
          .eq('school_id', schoolId) // Ensure student belongs to the correct school
          .single();
      return Student.fromMap(response);
    } catch (e) {
      print('Error fetching student by ID $studentId for school $schoolId: $e');
      return null;
    }
  }
}
