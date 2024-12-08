import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';
import 'add_task_dialog.dart';
import 'task_card.dart';

class StudentPlannerPage extends StatefulWidget {
  const StudentPlannerPage({super.key});

  @override
  _StudentPlannerPageState createState() => _StudentPlannerPageState();
}

class _StudentPlannerPageState extends State<StudentPlannerPage> {
  final TaskController _taskController = TaskController();
  List<Task> tasks = [];

  // Calendar-related variables
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _showAddTaskDialog() async {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onTaskAdded: (description, dueDate, dueTime, priority) async {
          // Safely convert dueDate to DateTime
          DateTime? normalizedDueDate;
          try {
            // Handle different input types
            if (dueDate is String) {
              // Parse the date and ensure it's in local time
              normalizedDueDate = DateTime.parse(dueDate as String);
            } else if (dueDate is DateTime) {
              // If it's already a DateTime, use it directly
              normalizedDueDate = dueDate;
            } else {
              throw FormatException('Invalid date format');
            }

            // Ensure the date is at midnight in the local time zone
            normalizedDueDate = DateTime(normalizedDueDate.year,
                normalizedDueDate.month, normalizedDueDate.day);
          } catch (e) {
            print('Date conversion error: $e');
            normalizedDueDate = DateTime.now();
          }

          final success = await _taskController.addTask(
            context: this.context,
            description: description,
            dueDate: normalizedDueDate,
            dueTime: dueTime,
            priority: priority,
          );

          if (success) {
            await _loadTasks();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add task')),
            );
          }
        },
      ),
    );
  }

  Future<void> _loadTasks() async {
    try {
      final fetchedTasks = await _taskController.fetchTasks();
      setState(() {
        tasks = fetchedTasks;

        // Organize tasks by normalized date
        _eventsByDay = {};
        for (var task in tasks) {
          // Safely parse the due date
          DateTime? taskDate;
          try {
            taskDate = _parseDateSafely(task.dueDate);
          } catch (e) {
            print('Error parsing task date: $e');
            continue; // Skip this task if date parsing fails
          }

          // Normalize the date to midnight in the local time zone
          final normalizedDate =
              DateTime(taskDate.year, taskDate.month, taskDate.day);

          // Add task to the appropriate date in the map
          if (!_eventsByDay.containsKey(normalizedDate)) {
            _eventsByDay[normalizedDate] = [];
          }
          _eventsByDay[normalizedDate]!.add(task);
        }
      });
    } catch (e) {
      print('Error loading tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
    }
  }

// Robust date parsing method
  DateTime _parseDateSafely(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }

    try {
      // Parse the date and ensure it's in local time
      DateTime parsedDate = DateTime.parse(dateString);

      // Return the date at midnight in the local time zone
      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    } catch (e) {
      print('Failed to parse date: $dateString');
      return DateTime.now();
    }
  }

  // Safely get tasks for a specific day
  List<Task> _getTasksForDay(DateTime day) {
    // Normalize the selected day to midnight in the local time zone
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner & Organizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentDate,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _showAddTaskDialog,
                  child: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Calendar Widget
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getTasksForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                markerSize: 7, // Adjust the size of the marker
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            // Tasks for selected day
            if (_selectedDay != null) ...[
              Text(
                'Tasks on ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _getTasksForDay(_selectedDay!).length,
                  itemBuilder: (context, index) {
                    final dayTasks = _getTasksForDay(_selectedDay!);
                    return TaskCard(
                      task: dayTasks[index],
                      onDelete: () async {
                        final success = await _taskController
                            .deleteTask(dayTasks[index].id);
                        if (success) {
                          await _loadTasks();
                        }
                      },
                    );
                  },
                ),
              ),
            ] else
              // If no day is selected, show all tasks
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: tasks[index],
                      onDelete: () async {
                        final success =
                            await _taskController.deleteTask(tasks[index].id);
                        if (success) {
                          setState(() {
                            tasks.removeAt(index);
                          });
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
