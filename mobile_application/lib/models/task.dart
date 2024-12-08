// models/task.dart
import 'package:intl/intl.dart';

class Task {
  final String id;
  final String userId;
  final String description;
  final String dueDate;
  final String? dueTime;
  final String priority;

  Task({
    required this.id,
    required this.userId,
    required this.description,
    required this.dueDate,
    this.dueTime,
    required this.priority,
  });

  // Factory method to create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: _convertToString(json['id']),
      userId: _convertToString(json['user_id']),
      description: _convertToString(json['description'] ?? 'No Description'),
      dueDate: _convertToDateString(json['due_date']),
      dueTime: _convertToTimeString(json['due_time']),
      priority: _convertToString(json['priority'] ?? 'Low'),
    );
  }

  // Convert Task to JSON for database insertion
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'description': description,
      'due_date': dueDate,
      'due_time': dueTime,
      'priority': priority,
    };
  }

  // Utility method to convert various inputs to string
  static String _convertToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Utility method to convert date to string
  static String _convertToDateString(dynamic date) {
    if (date == null) return '';

    if (date is DateTime) {
      return DateFormat('yyyy-MM-dd').format(date);
    }

    if (date is String) {
      try {
        // Try parsing the string as a DateTime
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        return date;
      }
    }

    return date.toString();
  }

  // Utility method to convert time to string
  static String? _convertToTimeString(dynamic time) {
    if (time == null) return null;

    if (time is DateTime) {
      return DateFormat('HH:mm').format(time);
    }

    if (time is String) {
      return time;
    }

    return time.toString();
  }
}
