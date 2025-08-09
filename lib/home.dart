import 'package:flutter/material.dart';
import 'package:sqflite_db/models/task.dart';
import 'package:sqflite_db/services/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _task = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sqflite',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _tasksList(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Input Task Name...'),
                ),
                const SizedBox(
                  height: 16,
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_task == null || _task == "")
                      return; // skip empty string
                    _databaseService
                        .addTask(_task!); // add task if string != empty

                    // trigger setState for empty the current task
                    setState(() {
                      _task = null;
                    });

                    // pop the dialog after task added
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    "Add Task",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(
        Icons.add,
      ),
    );
  }

  Widget _tasksList() {
    return FutureBuilder(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            Task task = snapshot.data![index];
            return ListTile(
              title: Text(
                task.content,
              ),
              trailing: Checkbox(
                value: task.status == 1,
                onChanged: (value) {
                  _databaseService.updateTaskStatus(
                      task.id, value == true ? 1 : 0);
                  setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
}
