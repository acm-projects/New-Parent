import 'package:client/widgets/dotted_divider.dart';
import 'package:flutter/material.dart';

Future<void> showEditDialog({
  required BuildContext context,
  required String label,
  required Widget field,
  required Function updateData,
  required GlobalKey<FormState> formKey,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        actionsPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        title: Text(
          label,
          style: Theme.of(context).textTheme.headline2,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DottedDivider(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Form(
                    key: formKey,
                    child: field,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            child: SizedBox(
              width: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(
            width: 16,
          ),
          OutlinedButton(
            child: SizedBox(
              width: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'Save',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                updateData();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
