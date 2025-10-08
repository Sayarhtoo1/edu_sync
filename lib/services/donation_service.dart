import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation.dart';
import '../utils/logger.dart';

class DonationService {
  final SupabaseClient _supabase;

  DonationService(this._supabase);

  Future<List<Donation>> getDonationsBySchool(int schoolId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select()
          .eq('school_id', schoolId)
          .order('donation_date', ascending: false);
      return (response as List).map((e) => Donation.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching donations: $e');
      return [];
    }
  }

  Future<List<Donation>> getDonationsByDonator(String donatorId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select()
          .eq('donator_id', donatorId)
          .order('donation_date', ascending: false);
      return (response as List).map((e) => Donation.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching donator donations: $e');
      return [];
    }
  }

  Future<Donation?> createDonation(Donation donation) async {
    try {
      final response = await _supabase
          .from('donations')
          .insert(donation.toJson())
          .select()
          .single();
      return Donation.fromJson(response);
    } catch (e) {
      logger.e('Error creating donation: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getDonationSummary(int schoolId) async {
    try {
      final response = await _supabase
          .from('donations')
          .select()
          .eq('school_id', schoolId)
          .eq('status', 'Received');
      
      double total = 0;
      int count = 0;
      for (var donation in response) {
        total += (donation['amount'] as num).toDouble();
        count++;
      }
      
      return {
        'total_amount': total,
        'total_donations': count,
        'donations': response,
      };
    } catch (e) {
      logger.e('Error fetching donation summary: $e');
      return {'total_amount': 0.0, 'total_donations': 0, 'donations': []};
    }
  }
}
