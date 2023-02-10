import 'package:flutter/material.dart';

import 'package:client/models/todo.dart';
import 'package:client/widgets/todo_widget.dart';
import 'package:client/models/app_user.dart';

class CompletedListWidget extends StatefulWidget {
  const CompletedListWidget({Key? key}) : super(key: key);

  @override
  _CompletedListWidgetState createState() => _CompletedListWidgetState();
}

class _CompletedListWidgetState extends State<CompletedListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AppUser.updateStream,
      builder: (context, snapshot) {
        List<Todo> completed = AppUser.currentUser?.todosCompleted ?? [];
        return completed.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 128.0),
                  child: Text(
                    'No Completed Tasks',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
              )
            : ListView.separated(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) => Container(height: 8),
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final todo = completed[index];

                  return TodoWidget(todo: todo);
                },
              );
      },
    );
  }
}
