//------show error massage---
import 'package:flutter/material.dart';

void showErrorDialog(error,BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('خطأ'),
        content: Text(error),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'تمام'),
            child: const Text(
              'تمام',
              style: TextStyle(
                  color: Color.fromRGBO(116, 98, 133, 1), fontSize: 15),
            ),
          ),
        ],
      );
    },
  );
}