import 'package:flutter/material.dart';

void showErrorAlertDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    barrierDismissible: false, //Prevents the dialog from being closed when clicked outside
    builder: (context) => AlertDialog(
      title: Text("PROGEAR"),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), //Close the dialog
          child: Text("OK"),
        ),
      ],
    ),
  );
}