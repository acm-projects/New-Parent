import 'package:flutter/material.dart';

class TodoFormWidget extends StatelessWidget {
  final TextEditingController title;
  final TextEditingController description;

  const TodoFormWidget(this.title, this.description, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 128.0),
            child: buildTitle(),
          ),
          const SizedBox(height: 8),
          buildDescription(),
        ],
      ),
    );
  }

  Widget buildTitle() {
    return TextFormField(
      controller: title,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Title',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'title cannot be empty';
        }
        return null;
      },
    );
  }

  Widget buildDescription() {
    return TextFormField(
      maxLines: 3,
      controller: description,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Description',
      ),
    );
  }
}
