import 'package:flutter/material.dart';
import '../../../data/database_helper.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E385A),
            Color(0xFF6C5E82),
            Color(0xFFA091A7),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: Text("Add Task", style: tt.titleLarge),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: tt.bodyLarge,
                decoration: const InputDecoration(
                  hintText: "Task title...",
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) return;

                    final task = Task(
                      title: title,
                      isDone: false,
                    );

                    await DatabaseHelper.instance.insertTask(task);

                    if (!mounted) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text("Save"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
