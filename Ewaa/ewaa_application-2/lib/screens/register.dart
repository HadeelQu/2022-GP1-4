import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/infoDialog.dart';
import '../widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

import '../widgets/textFields.dart';
import 'package:phone_number/phone_number.dart';

class Register extends StatefulWidget {
  static const String screenRoute = "reister_page";
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  // we need to hash passward
  TextEditingController _passward = TextEditingController();
  TextEditingController _repeatePassward = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isloading = false;

  // to avoid memory problem we used disopse
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phoneNumber.dispose();
    _passward.dispose();
    _repeatePassward.dispose();

    super.dispose();
  }

  GlobalKey<FormState> formState = new GlobalKey<FormState>();
  void _showErrorDialog(error) {
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

  translateErrorMassage(errorMassage) {
    var errorAfterTranslate = "";
    switch (errorMassage) {
      case "[firebase_auth/email-already-in-use]":
        errorAfterTranslate = "الايميل مسجل مسبقًا";

        break;
      case "[firebase_auth/weak-password]":
        errorAfterTranslate = "كلمة المرور يجب ان تكون اكثر من خمسةاحرف";
        break;
      default:
        errorAfterTranslate = "غير معروف";
    }
    return errorAfterTranslate;
  }

  vaildateFields(_username, _email, _phoneNumber, _passward) async {
    try {
      setState(() {
        _isloading = true;
      });
      print("vaild");
      await _auth
          .createUserWithEmailAndPassword(email: _email, password: _passward)
          .then((value) {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user!.uid;

        FirebaseFirestore.instance.collection("Users").doc(userId).set({
          "id": userId,
          "userNamae": _username,
          "email": _email,
          "phoneNumber": _phoneNumber,
          "userImage": "",
          // image
        }).then((value) {
          _auth.currentUser?.sendEmailVerification().then((value) {
            showDialog(
                context: context,
                builder: (context) => ShowInfoDialog(
                    "تم إرسال رابط الى بريدك الالكتروني لتفعيل الحساب"));
            _auth.signOut();
            setState(() {
              _isloading = false;
            });
          });
        });
      });
      ;
      //Navigator.pushReplacementNamed(context, HomePage.screenRoute);
    } catch (error) {
      setState(() {
        _isloading = false;
      });
      var firstIndexOfErrorMss = error.toString().indexOf('[');
      var lastIndexOfErrorMss = error.toString().indexOf(']');

      var errorCode = error
          .toString()
          .substring(firstIndexOfErrorMss, lastIndexOfErrorMss + 1);
      print(errorCode);
      var errorAfterTranslate = translateErrorMassage(errorCode);
      _showErrorDialog(errorAfterTranslate);
      print(error.toString()[0]);
    }
  }

  submit() {
    final vaild = formState.currentState?.validate();
    FocusScope.of(context).unfocus();
    if (vaild != null) {
      if (vaild) {
        formState.currentState?.save();
        print(_email);
        print(_phoneNumber);
        vaildateFields(_username.text.trim(), _email.text.trim(),
            _phoneNumber.text.trim(), _passward.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: formState,
                  child: Column(
                    children: [
                      TextFields("اسم المستخدم", Icons.person,
                          TextInputType.text, _username, (username) {
                        if (username!.isEmpty) {
                          return "الرجاء ادخال اسم المستخدم";
                        }
                        return null;
                      }, null, false),
                      SizedBox(
                        height: 15,
                      ),
                      TextFields("البريد الالكتروني", Icons.email,
                          TextInputType.emailAddress, _email, (email) {
                        //  EmailValidator class will be used to validate the email address. It returns a bool value; if the email address is valid, the returned value is true; otherwise, the returned value is false.
                        bool isvalid = EmailValidator.validate(email!);
                        print(isvalid);
                        if (email.isEmpty) {
                          return "الرجاء ادخال البريد الالكتروني";
                        } else if (!isvalid) {
                          return "الايميل غير صحيح";
                        }
                        return null;
                      }, null, false),
                      SizedBox(
                        height: 15,
                      ),
                      TextFields("رقم الهاتف", Icons.phone, TextInputType.phone,
                          _phoneNumber, (phoneNumber) {
                        // to check if the phone number is saudi we used RegExp
                        var regex = RegExp(
                            r"^(009665|9665|\+9665|05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$");
                        String patttern = r'(^[0-9]*$)';
                        RegExp regExp = new RegExp(patttern);
                        if (phoneNumber!.isEmpty) {
                          return "الرجاء ادخال رقم الهاتف";
                        }
                        if (!regex.hasMatch(phoneNumber)) {
                          return "رقم الهاتف غير صحيح";
                        }

                        return null;
                      }, null, false),
                      SizedBox(
                        height: 15,
                      ),
                      TextFields(
                        "كلمه المرور",
                        Icons.key,
                        TextInputType.visiblePassword,
                        _passward,
                        (passward) {
                          if (passward.toString().isEmpty) {
                            return "يرجى ادخال كلمه المرور";
                          }
                        },
                        Icons.remove_red_eye,
                        true,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFields(
                        "اعاده كلمة المرور ",
                        Icons.key,
                        TextInputType.visiblePassword,
                        _repeatePassward,
                        (repeatePassward) {
                          if (repeatePassward.toString().isEmpty) {
                            return "يرجى ادخال تاكيد كلمه المرور";
                          }
                          if (_passward.text != _repeatePassward.text) {
                            return "كلمه المرور غير متطابقة";
                          }
                          return null;
                        },
                        Icons.remove_red_eye,
                        true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _isloading
                  ? Center(
                      child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 155, 140, 181)),
                            backgroundColor: Style.purpole,
                          )),
                    )
                  : MyButton(
                      color: Style.buttonColor_pink,
                      title: "تسجيل الحساب",
                      onPeressed: submit,
                      minwidth: 180,
                      circular: 100,
                    ),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, HomePage.screenRoute);
                      },
                      child: Text(
                        "تخطي",
                        style: TextStyle(
                          color: Style.buttonColor_pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'ElMessiri',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("لديك حساب؟",
                        style: Theme.of(context).textTheme.headline3),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, Login.screenRoute);
                      },
                      child: Text(
                        "تسجيل الدخول",
                        style: TextStyle(
                          color: Style.buttonColor_pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'ElMessiri',
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
