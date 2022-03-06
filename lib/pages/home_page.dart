import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hive_to_do_app/data/local_storage.dart';
import 'package:hive_to_do_app/main.dart';
import 'package:hive_to_do_app/models/task_model.dart';
import 'package:hive_to_do_app/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    //_allTasks.add(Task.create(name: 'Deneme Task', createdAt: DateTime.now()));
    _getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet(context);
          },
          child: const Text(
            'Bugün Neler Yapacaksın',
            style: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              _showAddTaskBottomSheet(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _oankiListeElemani = _allTasks[index];
                return Dismissible(
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Bu görev silindi'),
                      ],
                    ),
                    key: Key(_oankiListeElemani.id),
                    onDismissed: (direction) {
                      _allTasks.removeAt(index);
                      _localStorage.deleteTask(task: _oankiListeElemani);
                      setState(() {});
                    },
                    child: TaskItem(task: _oankiListeElemani));
              },
              itemCount: _allTasks.length,
            )
          : const Center(
              child: Text('Görev Eklemeniz Gerekmektedir'),
            ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                autofocus: true,
                style: const TextStyle(fontSize: 24),
                decoration: const InputDecoration(
                  hintText: 'Görev nedir?',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  Navigator.of(context)
                      .pop(); // veriyi aldıktan sonra task ı kapatıyor
                  if (value.length > 3) {
                    DatePicker.showTimePicker(context, showSecondsColumn: false,
                        onConfirm: (time) async {
                      var newAddTask = Task.create(
                          name: value,
                          createdAt:
                              time); // bunun sayesinde yeni task olusturuldu ve saat bilgisi verildi
                      _allTasks.insert(0, newAddTask);
                      await _localStorage.addTask(task: newAddTask);
                      setState(() {});
                    });
                  }
                },
              ),
            ),
          );
        });
  }

  void _getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }
}
