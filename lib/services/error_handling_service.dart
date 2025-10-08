import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final Logger _logger = Logger();

  Future<T> handleAsyncOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    VoidCallback? onError,
    bool showSnackBar = true,
    BuildContext? context,
  }) async {
    try {
      return await operation();
    } catch (e) {
      _logger.e('Error in $operationName: $e');

      if (showSnackBar && context != null) {
        _showErrorSnackBar(context, 'Error in $operationName: ${e.toString()}');
      }

      onError?.call();
      rethrow;
    }
  }

  void handleSyncOperation({
    required Function() operation,
    required String operationName,
    VoidCallback? onError,
    bool showSnackBar = true,
    BuildContext? context,
  }) {
    try {
      operation();
    } catch (e) {
      _logger.e('Error in $operationName: $e');

      if (showSnackBar && context != null) {
        _showErrorSnackBar(context, 'Error in $operationName: ${e.toString()}');
      }

      onError?.call();
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String getErrorMessage(dynamic error) {
    if (error == null) return 'Unknown error occurred';

    if (error is String) return error;

    if (error.toString().contains('Connection failed')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (error.toString().contains('unauthorized') || error.toString().contains('401')) {
      return 'You are not authorized to perform this action.';
    }

    if (error.toString().contains('forbidden') || error.toString().contains('403')) {
      return 'You do not have permission to perform this action.';
    }

    if (error.toString().contains('not found') || error.toString().contains('404')) {
      return 'The requested resource was not found.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  bool isNetworkError(dynamic error) {
    if (error == null) return false;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket');
  }

  bool isAuthError(dynamic error) {
    if (error == null) return false;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unauthorized') ||
           errorString.contains('401') ||
           errorString.contains('forbidden') ||
           errorString.contains('403') ||
           errorString.contains('auth');
  }
}
