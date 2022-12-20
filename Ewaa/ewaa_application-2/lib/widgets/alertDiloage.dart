import 'package:flutter/material.dart';

class ShoeDialog extends StatefulWidget {
  var error;
  ShoeDialog(this.error);

  @override
  State<ShoeDialog> createState() => _ShoeDialogState(error);
}

class _ShoeDialogState extends State<ShoeDialog> {
  var error;
  _ShoeDialogState(this.error);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('error'),
      content: Text(error),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
