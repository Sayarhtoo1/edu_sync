import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/utils/logger.dart';
import 'cache_service.dart';

class ApiService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();
  final Connectivity _connectivity = Connectivity();

  Future<T> fetchData<T>({
    required Future<T> Function() onlineRequest,
    required Future<T> Function() offlineRequest,
    required Future<void> Function(T data) cacheData,
  }) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await offlineRequest();
    } else {
      try {
        final data = await onlineRequest();
        await cacheData(data);
        return data;
      } catch (e) {
        logger.e('Error during online request, falling back to cache: $e');
        return await offlineRequest();
      }
    }
  }
}