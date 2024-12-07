import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskController {
  final _supabase = Supabase.instance.client;
  static const String defaultUserId = '1';

  Future<List<Task>> fetchTasks() async {
    try {
      final response =
          await _supabase.from('task').select().eq('user_id', defaultUserId);

      return response.map((task) => Task.fromJson(task)).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  Future<bool> addTask({
    required BuildContext context,
    required String description,
    required DateTime dueDate,
    required TimeOfDay dueTime,
    required String priority,
  }) async {
    try {
      // Convert dueDate to UTC before saving
      DateTime utcDueDate = dueDate.toUtc();

      // Format the UTC due date as ISO 8601 string
      String formattedDueDate = DateFormat('yyyy-MM-dd').format(utcDueDate);

      final task = Task(
        id: DateTime.now().toString(), // Temporary client-side ID
        userId: defaultUserId,
        description: description,
        dueDate: formattedDueDate, // Store UTC date
        dueTime: dueTime.format(context),
        priority: priority,
      );

      // Insert the task into the database
      await _supabase.from('task').insert(task.toJson());
      return true;
    } catch (e) {
      print('Error adding task to Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _supabase.from('task').delete().eq('id', taskId);
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Utility method to get priority color
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
