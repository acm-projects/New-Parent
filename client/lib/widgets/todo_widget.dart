import 'package:client/widgets/edit_dialog.dart';
import 'package:client/widgets/todo_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:client/models/todo.dart';
import 'package:client/models/app_user.dart';

class TodoWidget extends StatelessWidget {
  final Todo todo;
  final _formKey = GlobalKey<FormState>();

  TodoWidget({
    required this.todo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Slidable(
        actionPane: const SlidableDrawerActionPane(),
        key: Key(todo.id),
        actions: [
          IconSlideAction(
            onTap: () async {
              final title = TextEditingController(text: todo.title);
              final description = TextEditingController(text: todo.description);

              await showEditDialog(
                  context: context,
                  label: "Edit Todo",
                  field: TodoFormWidget(title, description),
                  updateData: () {
                    todo.title = title.text;
                    todo.description = description.text;

                    AppUser.currentUser?.updateTodo(todo);
                  },
                  formKey: _formKey);
            },
            color: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            caption: 'Edit',
            icon: Icons.edit,
          )
        ],
        secondaryActions: [
          IconSlideAction(
            onTap: () => deleteTodo(context, todo),
            color: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            caption: 'Delete',
            icon: Icons.delete,
          )
        ],
        child: buildTodo(context),
      ),
    );
  }

  Widget buildTodo(BuildContext context) {
    return Container(
      color: Colors.white38,
      padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
      child: Row(
        children: [
          Checkbox(
            activeColor: Theme.of(context).colorScheme.primary,
            checkColor: Theme.of(context).colorScheme.onPrimary,
            value: todo.isDone,
            onChanged: (_) {
              final isDone = AppUser.currentUser!.toggleTodoStatus(todo);

              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1250),
                  content: Text(isDone ? 'Task Completed' : 'Task Incomplete'),
                ),
              );
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                if (todo.description.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Text(todo.description,
                        style: Theme.of(context).textTheme.subtitle1),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void deleteTodo(BuildContext context, Todo todo) {
    AppUser.currentUser!.removeTodo(todo);

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1250),
        content: Text('Task Deleted'),
      ),
    );
  }
}
