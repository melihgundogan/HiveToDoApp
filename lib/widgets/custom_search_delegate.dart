import 'package:flutter/material.dart';
import 'package:hive_to_do_app/data/local_storage.dart';
import 'package:hive_to_do_app/main.dart';
import 'package:hive_to_do_app/models/task_model.dart';
import 'package:hive_to_do_app/widgets/task_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    // arama kısmının sag kısmındaki iconları
    return [
      IconButton(
          onPressed: () {
            query.isEmpty ? null : query = '';
          },
          icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // sol bastaki iconları
    return GestureDetector(
        onTap: () {
          close(context, null);
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.red,
          size: 24,
        ));
  }

  @override
  Widget buildResults(BuildContext context) {
    // bir aramayı yapıp cıkan sonucları nasıl gosterilecegi
    List<Task> filteredList = allTasks.where((element) => element.name.toLowerCase().contains(query.toLowerCase())).toList();
    return filteredList.length > 0 ? ListView.builder(
              itemBuilder: (context, index) {
                var _oankiListeElemani = filteredList[index];
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
                    onDismissed: (direction) async {
                      filteredList.removeAt(index);
                      await locator<LocalStorage>().deleteTask(task: _oankiListeElemani);
                    },
                    child: TaskItem(task: _oankiListeElemani));
              },
              itemCount: filteredList.length,
            ) : Center(child: Text(AppLocalizations.of(context).search_not_found),);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // hic birsey yazılmadıgında veya 1 2 harf yazıldıgında gosterilmesi gereken

    return Container();
  }
}
