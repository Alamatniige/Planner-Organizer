import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/task_list_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ybbiyaxcyqnmpiswdcsc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliYml5YXhjeXFubXBpc3dkY3NjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1NDQxODgsImV4cCI6MjA0OTEyMDE4OH0.3AJo66nCxDhCop_gvzBQvkK1AcvUP9TvH2z2d_st6Ao',
  );

  runApp(const MyApp());
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
      home: const StudentPlannerPage(),
    );
  }
}
