import 'package:flutter/material.dart';

class ShowInfoDialog extends StatefulWidget {
  var info;
  ShowInfoDialog(this.info);

  @override
  State<ShowInfoDialog> createState() => _ShowInfoDialogState(info);
}

class _ShowInfoDialogState extends State<ShowInfoDialog> {
  var info;
  _ShowInfoDialogState(this.info);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      titleTextStyle: TextStyle(color: Colors.black87),
      title: const Text('معلومات'),
      content: Text(info),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'موافق'),
          child: const Text(
            'موافق',
            style:
                TextStyle(color: Color.fromRGBO(116, 98, 133, 1), fontSize: 15),
          ),
        ),
      ],
    );
  }
}
