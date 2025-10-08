import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolSettings {
  final String? id;
  final double latitude;
  final double longitude;
  final int radius;

  SchoolSettings({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory SchoolSettings.fromJson(Map<String, dynamic> json) {
    return SchoolSettings(
      id: json['id'] as String?,
      latitude: (json['location_latitude'] as num).toDouble(),
      longitude: (json['location_longitude'] as num).toDouble(),
      radius: json['attendance_radius_meters'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_latitude': latitude,
      'location_longitude': longitude,
      'attendance_radius_meters': radius,
    };
  }
}

class SchoolSettingsNotifier extends StateNotifier<SchoolSettings?> {
  final SupabaseClient _supabase = Supabase.instance.client;

  SchoolSettingsNotifier() : super(null) {
    fetchSchoolSettings();
  }

  Future<void> fetchSchoolSettings() async {
    try {
      final response = await _supabase
          .from('school_settings')
          .select('*')
          .limit(1)
          .single();
      state = SchoolSettings.fromJson(response);
    } catch (e) {
      print('Error fetching school settings: $e');
      state = null;
    }
  }

  Future<void> saveSchoolSettings(
      double latitude, double longitude, double radius, String schoolId) async {
    try {
      final Map<String, dynamic> data = {
        'location_latitude': latitude,
        'location_longitude': longitude,
        'attendance_radius_meters': radius.toInt(),
        'school_id': schoolId,
      };

      if (state == null) {
        final response =
            await _supabase.from('school_settings').insert(data).select().single();
        state = SchoolSettings.fromJson(response);
      } else {
        final response = await _supabase
            .from('school_settings')
            .update(data)
            .eq('id', state!.id!)
            .select()
            .single();
        state = SchoolSettings.fromJson(response);
      }
    } catch (e) {
      print('Error saving school settings: $e');
    }
  }
}

final schoolSettingsProvider = StateNotifierProvider<SchoolSettingsNotifier, SchoolSettings?>((ref) {
  return SchoolSettingsNotifier();
});