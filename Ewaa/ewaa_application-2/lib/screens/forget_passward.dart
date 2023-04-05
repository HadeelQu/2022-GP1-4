import 'package:email_validator/email_validator.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/button.dart';
import '../widgets/textFields.dart';

class ForgfetPassward extends StatefulWidget {
  const ForgfetPassward({Key? key}) : super(key: key);
  static const String screenRoute = "ForgetPssward_page";

  @override
  State<ForgfetPassward> createState() => _ForgfetPasswardState();
}

class _ForgfetPasswardState extends State<ForgfetPassward> {
  TextEditingController _email = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future passwardRes() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());
      Fluttertoast.showToast(
          msg: "تم ارسال رابط اعادة التعيين على الايميل",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Style.textFieldsColor_lightpink,
          textColor: Style.purpole,
          fontSize: 16.0);
      Navigator.pushReplacementNamed(context, Login.screenRoute);
    } catch (e) {
      print(e);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('خطا'),
            content: Text("الايميل غير موجود"),
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent, //transparent
                elevation: 0.0,
                iconTheme: IconThemeData(color: Style.black, size: 28),
                toolbarHeight: 75,
                leading: Text(""),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.arrow_forward_sharp,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.popAndPushNamed(context, Login.screenRoute);
                      }),
                ]),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    height: 130,
                    child: Image.asset("images/logo.png"),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: Center(
                      child: Text(
                        "إيواء",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Text(
                      "اعاده تعيين كلمه المرور",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(25),
                    child: TextFields("البريد الالكتروني", Icons.email,
                        TextInputType.emailAddress, _email, (_email) {
                      bool isvalid = EmailValidator.validate(_email!);
                      print(isvalid);
                      if (_email.isEmpty) {
                        return "الرجاء ادخال البريد الالكتروني";
                      } else if (!isvalid) {
                        return "الايميل غير صحيح";
                      }
                      return null;
                    }, null, false),
                  ),
                  MyButton(
                    color: Style.buttonColor_pink,
                    title: "ارسال طلب اعادة تعيين",
                    onPeressed: passwardRes,
                    minwidth: 180,
                    circular: 100,
                  ),
                ],
              ),
            )));
  }
}
