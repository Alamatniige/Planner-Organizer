import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Planner & Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StudentPlannerPage(),
    );
  }
}

class StudentPlannerPage extends StatefulWidget {
  const StudentPlannerPage({super.key});

  @override
  _StudentPlannerPageState createState() => _StudentPlannerPageState();
}

class _StudentPlannerPageState extends State<StudentPlannerPage> {
  List<Task> tasks = [
    Task('Math Assignment', '10:00 AM', 'High'),
    Task('Science Lab Report', '1:00 PM', 'Medium'),
    Task('History Presentation', '3:00 PM', 'Low'),
  ];

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    String priority = 'Low';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              DropdownButton<String>(
                value: priority,
                onChanged: (newValue) {
                  setState(() {
                    priority = newValue!;
                  });
                },
                items: ['High', 'Medium', 'Low']
                    .map((priorityOption) => DropdownMenuItem<String>(
                          value: priorityOption,
                          child: Text(priorityOption),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.add(Task(
                    titleController.text,
                    timeController.text,
                    priority,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Planner & Organizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Date and Add Task Button
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
            // Calendar View Placeholder (can be enhanced with actual calendar widget)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.blue.shade100,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Calendar View (Week)', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                      task: tasks[index],
                      onDelete: () {
                        setState(() {
                          tasks.removeAt(index);
                        });
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String time;
  final String priority;

  Task(this.title, this.time, this.priority);
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            Text(task.time, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Text(
              'Priority: ${task.priority}',
              style: TextStyle(
                color: task.priority == 'High'
                    ? Colors.red
                    : task.priority == 'Medium'
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
