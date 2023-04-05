import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/addP.dart';
import 'package:ewaa_application/screens/adoption_form.dart';
import 'package:ewaa_application/screens/edit_profile.dart';
import 'package:ewaa_application/screens/history.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/my_pets_screen.dart';
import 'package:ewaa_application/screens/my_requests.dart';
import 'package:ewaa_application/screens/requests_log.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/pet_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/button.dart';
import '../widgets/myTextButton.dart';

import '../style.dart';

class ProfilePage extends StatefulWidget {
  static const String screenRoute = "Profile_page";

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  TextEditingController _petName = TextEditingController();
  File? imageFile;

  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  var currentImage;
  var username;
  var petname;

  bool _isloading = false;

  late var userName;
  late var usreImage;

  //

  final _auth = FirebaseAuth.instance;
  late User siginUser;

  getLimitMyPets() {
    siginUser = _auth.currentUser!;
    Stream<QuerySnapshot<Map<String, dynamic>>> pets = FirebaseFirestore
        .instance
        .collection("pets")
        .where('ownerId', isEqualTo: siginUser.uid)
        .where("isAdopted", isEqualTo: false)
        .limit(2)
        .snapshots();
    return pets;
  }

  void getData() async {
    try {
      final _user = _auth.currentUser;
      if (_user != null) {
        siginUser = _user;
        final DocumentSnapshot userInfo = await FirebaseFirestore.instance
            .collection('Users')
            .doc(siginUser.uid)
            .get();

        setState(() {
          userName = userInfo.get("userNamae");
          usreImage = userInfo.get("userImage");
          currentImage = usreImage;
          username = userName;

          _isloading = true;
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

  //--------------section ------------------------------------
  Widget buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.only(left: 26, right: 26),
      alignment: Alignment.topRight,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Style.black,
          fontSize: 24,
          fontFamily: 'ElMessiri',
        ),
      ),
    );
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

  //--------------initState------------------------------------
  @override
  void initState() {
    super.initState();
    getData();
  }

  //------show error massage---
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

  @override
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: getProfilePageAppBar(context),
        drawer: listView(),
        body: !_isloading
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
                              margin: EdgeInsets.only(
                                  bottom: 5, left: 26, right: 26),
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
                              margin: EdgeInsets.only(
                                  bottom: 5, left: 26, right: 26),
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
                      Center(
                        child: Container(
                          child: Text(
                            userName,
                            style: TextStyle(
                              color: Style.purpole,
                              fontSize: 18,
                              fontFamily: 'ElMessiri',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: getUserProfile(),
                          builder: (context, snapshot) {
                            return Center(
                              child: Container(
                                height: 36,
                                child: MyButton2(
                                    color: Style.buttonColor_pink,
                                    title: "تعديل الملف الشخصي",
                                    onPeressed: () {
                                      Navigator.pushNamed(
                                          context, EditProfilePage.screenRoute);
                                    }),
                              ),
                            );
                          }),

                      //=======================================
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 210,
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: Text(
                                        "حيواناتى الأليفة المضافة",
                                        style: TextStyle(
                                            fontFamily: 'ElMessiri',
                                            fontSize: 14,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        child: Text(
                                          " الكل > ",
                                          style: TextStyle(
                                              fontFamily: 'ElMessiri',
                                              fontSize: 14,
                                              color: Style.purpole),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, MyPetsPage.screenRoute);
                                        },
                                      ),
                                    )
                                  ]),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: getLimitMyPets(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text("يوجد خطأ"),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: Container(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color.fromARGB(
                                                      255, 155, 140, 181)),
                                          backgroundColor: Style.purpole,
                                        )),
                                  );
                                } else if (snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Container(
                                      height: 50,
                                      margin: EdgeInsets.only(
                                          left: 50, right: 50, top: 50),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Style.textFieldsColor_lightpink,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Text(
                                          "لا توجد حيوانات أليفة متوفرة",
                                          style: TextStyle(
                                            color:
                                                Style.purpole.withOpacity(0.8),
                                            fontFamily: 'ElMessiri',
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: snapshot.data!.docs
                                                .map((doucument) {
                                              if (doucument['petName'] == "") {
                                                petname = doucument['category'];
                                              } else {
                                                petname = doucument['petName'];
                                              }
                                              return Container(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                child: myPetWidget(
                                                  img: doucument['image'],
                                                  name: petname,
                                                  breed: doucument['breed'],
                                                  gender: doucument['gender'],
                                                  age: 'العمر : ' +
                                                      doucument['age'],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ]),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      MyTextButton(
                        text: "إضافة حيوان أليف للتبني",
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.pushNamed(context, AddPets.screenRoute);
                        },
                      ),
                      MyTextButton(
                        text: "المعلومات اللازمة للتبني",
                        icon: Icons.info_outline,
                        onPressed: () {
                          Navigator.pushNamed(
                              context, AdoptionForm.screenRoute);
                        },
                      ),

                      MyTextButton(
                        text: "طلبات التبني",
                        icon: Icons.list,
                        onPressed: () {
                          Navigator.pushNamed(context, MyRequests.screenRoute);
                        },
                      ),

                      MyTextButton(
                        text: "عملياتي السابقة في التبني",
                        icon: Icons.history,
                        onPressed: () {
                          Navigator.pushNamed(context, History.screenRoute);
                        },
                      ),

                      Divider(
                        color: Colors.grey[500],
                      ),

                      MyTextButton(
                        text: "تسجيل الخروج",
                        icon: Icons.logout,
                        onPressed: () {
                          _auth.signOut();
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.pushReplacementNamed(
                              context, HomePage.screenRoute);
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}
