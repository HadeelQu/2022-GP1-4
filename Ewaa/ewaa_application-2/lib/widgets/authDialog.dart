import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../style.dart';

class ShowAuthDialog extends StatefulWidget {
  var info;
  ShowAuthDialog(this.info);

  @override
  State<ShowAuthDialog> createState() => _ShowAuthDialogState(info);
}

class _ShowAuthDialogState extends State<ShowAuthDialog> {
  var info;
  _ShowAuthDialogState(this.info);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      titleTextStyle: TextStyle(color: Colors.black87),
      title: const Text('معلومات'),
      content: Text(info),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'موافق');
            FirebaseAuth.instance.signOut();
          },
          child: const Text(
            'موافق',
            style:
                TextStyle(color: Color.fromRGBO(116, 98, 133, 1), fontSize: 15),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'إعادة إرسال');
            FirebaseAuth.instance.currentUser
                ?.sendEmailVerification()
                .then((value) {
              Fluttertoast.showToast(
                msg: "تمت إعادة إرسال الرابط الى بريدك",
                backgroundColor: Style.textFieldsColor_lightpink,
                textColor: Style.purpole,
              );
              FirebaseAuth.instance.signOut();
            }).catchError((e) {
              Fluttertoast.showToast(msg: e.toString());
            });
          },
          child: const Text(
            'إعادة إرسال',
            style:
                TextStyle(color: Color.fromRGBO(116, 98, 133, 1), fontSize: 15),
          ),
        ),
      ],
    );
  }
}
