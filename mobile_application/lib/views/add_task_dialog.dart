// views/add_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String description, DateTime dueDate, TimeOfDay dueTime,
      String priority) onTaskAdded;

  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController titleController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String priority = 'Low';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          const SizedBox(height: 10),
          // Date Selection
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedDate == null
                      ? 'No date selected'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2025),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          // Time Selection
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedTime == null
                      ? 'No time selected'
                      : selectedTime!.format(context),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
              ),
            ],
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty &&
                selectedDate != null &&
                selectedTime != null) {
              widget.onTaskAdded(
                titleController.text,
                selectedDate!,
                selectedTime!,
                priority,
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Please enter a title, select a date and time')),
              );
            }
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}
