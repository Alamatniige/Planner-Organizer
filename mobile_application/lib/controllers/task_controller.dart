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
      debugPrint('Error fetching tasks: $e');
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
      // Validate inputs
      if (description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Description cannot be empty')),
        );
        return false;
      }

      // Combine date and time
      DateTime combinedDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime.hour,
        dueTime.minute,
      );

      // Convert to UTC
      DateTime utcDateTime = combinedDateTime.toUtc();

      // Format the UTC date and time
      String formattedDueDate = DateFormat('yyyy-MM-dd').format(utcDateTime);
      String formattedDueTime = DateFormat('HH:mm').format(utcDateTime);

      final task = Task(
        id: DateTime.now().toString(), // Temporary client-side ID
        userId: defaultUserId,
        description: description,
        dueDate: formattedDueDate, // Store UTC date
        dueTime: formattedDueTime, // Store UTC time
        priority: priority,
      );

      // Insert the task into the database
      final response = await _supabase.from('task').insert(task.toJson());

      // Optional: Check the response if needed
      if (response == null) {
        debugPrint('Task inserted successfully');
        return true;
      } else {
        debugPrint('Failed to insert task');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding task to Supabase: $e');

      // Optional: Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: ${e.toString()}')),
      );

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
