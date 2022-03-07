import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hive_to_do_app/data/local_storage.dart';
import 'package:hive_to_do_app/main.dart';
import 'package:hive_to_do_app/models/task_model.dart';
import 'package:hive_to_do_app/widgets/custom_search_delegate.dart';
import 'package:hive_to_do_app/widgets/task_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            _showAddTaskBottomSheet(); // stateful widget icinde oldugumuzda context vermemize gerek kalmaz
          },
          child: Text(
            AppLocalizations.of(context).title,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              _showSearchPage();
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              _showAddTaskBottomSheet();
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
                      children: [
                        const Icon(Icons.delete, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).remove_task),
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
          : Center(
              child: Text(AppLocalizations.of(context).empty_task_list),
            ),
    );
  }

  void _showAddTaskBottomSheet() {
    // stateful widget icindeysek BuildContext context vermemizin bir anlamı yoktur
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
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).add_task,
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  Navigator.of(context)
                      .pop(); // veriyi aldıktan sonra task ı kapatıyor
                  if (value.length > 3) {
                    DatePicker.showTimePicker(context,
                        showSecondsColumn: false,
                        locale: LocaleType.tr, onConfirm: (time) async {
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

  Future<void> _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDb(); // arama yaptıktan sonra tum listeyi db den tekrar cagırıyoruz
  }
}
