import 'package:client/widgets/dotted_divider.dart';
import 'package:flutter/material.dart';

import 'package:client/models/app_user.dart';
import 'package:client/models/todo.dart';
import 'package:client/widgets/edit_dialog.dart';
import 'package:client/widgets/todo_form.dart';
import 'package:client/widgets/todo_list_widget.dart';
import 'package:client/widgets/completed_list_widget.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            colorFilter: ColorFilter.mode(Color(0x20FFFFFF), BlendMode.dstATop),
            image: AssetImage('assets/images/undraw_mother.png'),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                _todoDivider(),
                const SizedBox(height: 16),
                _completedDivider(),
                const SizedBox(height: 128),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              elevation: 0,
              onPressed: () async {
                final title = TextEditingController();
                final description = TextEditingController();

                await showEditDialog(
                    context: context,
                    label: "Add Todo",
                    field: TodoFormWidget(title, description),
                    updateData: () {
                      final todo = Todo(
                        id: DateTime.now().toString(),
                        title: title.text,
                        description: description.text,
                        createdTime: DateTime.now(),
                      );

                      AppUser.currentUser?.updateTodo(todo);
                    },
                    formKey: _formKey);
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _todoDivider() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: 'To Do', style: Theme.of(context).textTheme.headline1),
            ),
            const DottedDivider(),
          ],
        ),
        childrenPadding: EdgeInsets.zero,
        children: const [TodoListWidget()],
      ),
    );
  }

  Widget _completedDivider() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                  text: 'Completed',
                  style: Theme.of(context).textTheme.headline1),
            ),
            const DottedDivider(),
          ],
        ),
        childrenPadding: EdgeInsets.zero,
        children: const [CompletedListWidget()],
      ),
    );
  }
}
