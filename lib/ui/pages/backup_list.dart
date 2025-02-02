import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod_todo_app/models/list_of_todo_model.dart';
import 'package:flutter_riverpod_todo_app/ui/widgets/app_title.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/export_providers.dart';

class BackupList extends ConsumerWidget {
  const BackupList({required this.listOfFiles, Key? key}) : super(key: key);
  final List<String> listOfFiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageProvider);

    void _restoreBackup(ListOfTodoModel listOfTodoModel) {
      ref.read(todoListProvider.notifier)
        ..overrideData(listOfTodoModel)
        ..saveData();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data Restored"),
          backgroundColor: Colors.green,
        ),
      );
    }

    void _restoreDataAlert(ListOfTodoModel listOfTodoModel) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Restore this backup?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _restoreBackup(listOfTodoModel),
              child: Text(
                'Restore',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    void _showAlert(int index) async {
      ListOfTodoModel? listOfTodoModel = await storage.readData(
        File(listOfFiles[index]),
      );
      if (listOfTodoModel != null) {
        _restoreDataAlert(listOfTodoModel);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data is Empty!"),
          ),
        );
      }
    }

    void _shareBackup(int index) {
      storage.share(listOfFiles[index]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(
          leadingTitle: 'Backup',
          trailingTitle: 'List',
        ),
        centerTitle: true,
        actions: const [
          Icon(
            Icons.ac_unit,
            color: Colors.transparent,
          ),
          Icon(
            Icons.ac_unit,
            color: Colors.transparent,
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: listOfFiles.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                onTap: () => _showAlert(index),
                title: Text(
                  listOfFiles[index]

                      /// to show only the file name,
                      .substring(listOfFiles[index].length - 38,
                          listOfFiles[index].length),
                ),
                leading: const Icon(Icons.restore_rounded),
                trailing: TextButton(
                  onPressed: () => _shareBackup(index),
                  child: const Icon(Icons.share),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
