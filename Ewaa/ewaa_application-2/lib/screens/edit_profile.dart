import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/textFields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  static const String screenRoute = "edit_profile_page";

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _username = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  // to avoid memory problem we used disopse
  void dispose() {
    _username.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  File? imageFile;

  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  var currentImage;
  var username;

  var petname;

  bool _isloading = false;

  late var userName;
  late var usreImage;
  late var phone_number;
  final _auth = FirebaseAuth.instance;
  late User siginUser;
  void getData() async {
    try {
      final _user = _auth.currentUser;
      if (_user != null) {
        siginUser = _user;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(siginUser.uid)
            .get()
            .then((userInfo) {
          setState(() {
            userName = userInfo.get("userNamae");
            usreImage = userInfo.get("userImage");
            phone_number = userInfo.get("phoneNumber");
            currentImage = usreImage;
            username = userName;
            //init fields
            _username.text = userName;
            _phoneNumber.text = phone_number;
            _isloading = false;
          });
        });
      }
    } catch (error) {
      setState(() {
        _isloading = false;
      });
    }
  }

  getUserProfile() {
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  Future updateUserImage() async {
    try {
      siginUser = _auth.currentUser!;
      setState(() {
        _isloading = true;
      });
      final uId = siginUser.uid;
      final userImage2 =
          FirebaseStorage.instance.ref().child("usersImage").child(uId + "jpg");

      await userImage2.putFile(imageFile!);
      String url = await userImage2.getDownloadURL();
      print(url);
      await FirebaseFirestore.instance.collection("Users").doc(uId).update({
        "userImage": url,
      });
      setState(() {
        getData();
      });
    } catch (error) {
      print(error.toString());
      print("error to add");
      setState(() {
        _isloading = false;
      });
    }
  }

  //--------------uploade image from camera------------------------------------
  void pickImageCamera() async {
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxWidth: 1000, maxHeight: 1000);
    setState(() {
      imageFile = File(pickedFile!.path);

      updateUserImage();
    });
  }

  //--------------uploade image from gallery------------------------------------
  void pickImageGallery() async {
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000);
    setState(() {
      imageFile = File(pickedFile!.path);

      updateUserImage();
    });
  }

  //--------------uploade images------------------------------------
  uploadeImage(context) {
    showDialog(
        context: context,
        builder: (contex) {
          return AlertDialog(
            title: Text(
              "تحميل صوره من ",
              style: TextStyle(color: Style.buttonColor_pink),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              InkWell(
                onTap: pickImageCamera,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Style.purpole,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "كاميرا",
                        style: TextStyle(color: Style.purpole),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: pickImageGallery,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Style.purpole,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "معرض الصور",
                        style: TextStyle(color: Style.purpole),
                      )
                    ],
                  ),
                ),
              )
            ]),
          );
        });
  }

  vaildateFields(_username, _phoneNumber) async {
    try {
      setState(() {
        _isloading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;

      await FirebaseFirestore.instance.collection("Users").doc(userId).update({
        "userNamae": _username,
        "phoneNumber": _phoneNumber,
        // image
      }).then((value) {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, ProfilePage.screenRoute);
        Fluttertoast.showToast(
            msg: "تم تحديث المعلومات بنجاح",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Style.textFieldsColor_lightpink,
            textColor: Style.purpole,
            fontSize: 16.0);

        setState(() {
          _isloading = false;
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
      default:
        errorAfterTranslate = "غير معروف";
    }
    return errorAfterTranslate;
  }

  submit() {
    final vaild = formState.currentState?.validate();
    FocusScope.of(context).unfocus();
    if (vaild != null) {
      if (vaild) {
        formState.currentState?.save();
        vaildateFields(_username.text.trim(), _phoneNumber.text.trim());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: getProfilePageAppBar(context),
      drawer: listView(),
      body: _isloading
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
          : Column(children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    currentImage != ""
                        ? Container(
                            margin:
                                EdgeInsets.only(bottom: 5, left: 26, right: 26),
                            alignment: Alignment.center,
                            height: 130,
                            width: 200,
                            child: Stack(
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      usreImage,
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () {
                                      uploadeImage(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Style.buttonColor_pink,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                        : Container(
                            margin:
                                EdgeInsets.only(bottom: 5, left: 26, right: 26),
                            alignment: Alignment.center,
                            height: 130,
                            width: 200,
                            child: Stack(
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        AssetImage("images/profile.jpg"),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () {
                                      uploadeImage(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Style.buttonColor_pink,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      child: Form(
                          key: formState,
                          child: Column(children: [
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
                            TextFields(
                                "رقم الهاتف",
                                Icons.phone,
                                TextInputType.phone,
                                _phoneNumber, (phoneNumber) {
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
                          ])),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: _isloading
                          ? Container(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 155, 140, 181)),
                                backgroundColor: Style.purpole,
                              ))
                          : Container(
                              height: 36,
                              child: MyButton2(
                                color: Style.buttonColor_pink,
                                title: "تحديث",
                                onPeressed: submit,
                              ),
                            ),
                    ),

                    //=======================================
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ]),
    ));
  }
}
