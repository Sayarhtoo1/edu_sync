import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logger/logger.dart';

class PerformanceMetrics {
  final String operationName;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String? error;

  PerformanceMetrics({
    required this.operationName,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.error,
  });

  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'operation': operationName,
      'duration_ms': duration.inMilliseconds,
      'is_completed': isCompleted,
      'error': error,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }
}

class PerformanceMonitorService {
  static final PerformanceMonitorService _instance = PerformanceMonitorService._internal();
  factory PerformanceMonitorService() => _instance;
  PerformanceMonitorService._internal();

  final Logger _logger = Logger();
  final List<PerformanceMetrics> _metrics = [];
  static const int _maxMetrics = 100;

  Timer? _cleanupTimer;

  void startOperation(String operationName) {
    final metrics = PerformanceMetrics(
      operationName: operationName,
      startTime: DateTime.now(),
    );
    _metrics.add(metrics);
    _logger.d('Started operation: $operationName');

    _ensureCleanupTimer();
  }

  void completeOperation(String operationName, {String? error}) {
    final metrics = _metrics.where((m) => m.operationName == operationName && !m.isCompleted).toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.last;
      final updatedMetric = PerformanceMetrics(
        operationName: metric.operationName,
        startTime: metric.startTime,
        endTime: DateTime.now(),
        isCompleted: true,
        error: error,
      );

      final index = _metrics.indexOf(metric);
      _metrics[index] = updatedMetric;

      _logger.d('Completed operation: $operationName in ${updatedMetric.duration.inMilliseconds}ms');
    }
  }

  List<PerformanceMetrics> getMetrics({String? operationName, int limit = 20}) {
    var filteredMetrics = _metrics;

    if (operationName != null) {
      filteredMetrics = _metrics.where((m) => m.operationName == operationName).toList();
    }

    return filteredMetrics.take(limit).toList();
  }

  Map<String, double> getAverageDurations() {
    final Map<String, List<int>> durations = {};

    for (var metric in _metrics.where((m) => m.isCompleted && m.error == null)) {
      durations.putIfAbsent(metric.operationName, () => []).add(metric.duration.inMilliseconds);
    }

    final averages = <String, double>{};
    durations.forEach((operation, times) {
      final avg = times.reduce((a, b) => a + b) / times.length;
      averages[operation] = avg;
    });

    return averages;
  }

  void clearMetrics() {
    _metrics.clear();
  }

  void _ensureCleanupTimer() {
    _cleanupTimer ??= Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_metrics.length > _maxMetrics) {
        _metrics.removeRange(0, _metrics.length - _maxMetrics);
      }
    });
  }

  Widget buildPerformanceOverlay() {
    return Material(
      color: Colors.black54,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._metrics.take(5).map((metric) => Text(
              '${metric.operationName}: ${metric.duration.inMilliseconds}ms ${metric.error != null ? '(ERROR)' : ''}',
              style: TextStyle(
                color: metric.error != null ? Colors.red : Colors.green,
                fontSize: 12,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Extension for easy performance monitoring
extension PerformanceMonitorExtension on Object {
  Future<T> monitorPerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final monitor = PerformanceMonitorService();
    monitor.startOperation(operationName);

    try {
      final result = await operation();
      monitor.completeOperation(operationName);
      return result;
    } catch (e) {
      monitor.completeOperation(operationName, error: e.toString());
      rethrow;
    }
  }
}
