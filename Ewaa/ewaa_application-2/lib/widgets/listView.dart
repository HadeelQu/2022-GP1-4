import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/addP.dart';
import 'package:ewaa_application/screens/history.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/screens/my_pets_screen.dart';
import 'package:ewaa_application/screens/my_requests.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/screens/requests_log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ewaa_application/style.dart';

class listView extends StatefulWidget {
  @override
  State<listView> createState() => _listView();
}

class _listView extends State<listView> {
  final _auth = FirebaseAuth.instance;
  late var userName = "";
  late var email = "";
  late var image;
  late User siginUser;
  bool _isloading = false;
  var currentImage;

  getUser() async {
    try {
      final _user = _auth.currentUser;
      if (_user != null) {
        siginUser = _user;
        DocumentReference docOfCurrentUser = await FirebaseFirestore.instance
            .collection("Users")
            .doc(siginUser.uid);
        FirebaseFirestore.instance
            .collection("Users")
            .where("id", isEqualTo: siginUser.uid)
            .snapshots();
        final doc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(siginUser.uid)
            .get();

        setState(() {
          userName = doc.get('userNamae');
          email = doc.get("email");
          image = doc.get("userImage");
          currentImage = image;
          _isloading = true;
//  currentImage != ""
        });
      }
    } catch (error) {
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  UserImage() {
    try {
      if (currentImage == "")
        return AssetImage("images/profile.jpg");
      else
        return NetworkImage(currentImage);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: FutureBuilder(
      future: getUser(),
      builder: ((context, snapshot) {
        if (_auth.currentUser != null) {
          return ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 170,
                width: 160,
                color: Color.fromARGB(255, 249, 241, 241),
                child: !_isloading
                    ? Center(
                        child: Container(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 155, 140, 181)),
                            backgroundColor: Style.purpole,
                          ),
                        ),
                      )
                    : UserAccountsDrawerHeader(
                        accountName: Text(
                          userName,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        accountEmail: Text(
                          email,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: UserImage(),
                          backgroundColor: Colors.white,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 249, 241, 241),
                        ),
                      ),
              ),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Style.purpole,
                ),
                title: const Text(
                  "إضافة حيوان أليف للتبني",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'ElMessiri',
                    fontWeight: FontWeight.w200,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, AddPets.screenRoute);
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.pets,
                  color: Style.purpole,
                ),
                title: const Text(
                  "حيواناتي الأليفة المضافة",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'ElMessiri',
                    fontWeight: FontWeight.w200,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, MyPetsPage.screenRoute);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: Style.purpole,
                ),
                title: const Text(
                  "عملياتي السابقة في التبني",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'ElMessiri',
                    fontWeight: FontWeight.w200,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, History.screenRoute);
                },
              ),
              // ListTile(
              //   leading: Icon(
              //     Icons.help,
              //     color: Style.purpole,
              //   ),
              //   title: const Text(
              //     'المساعدة',
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontSize: 15,
              //       fontFamily: 'ElMessiri',
              //       fontWeight: FontWeight.w200,
              //     ),
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
              ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Style.purpole,
                  ),
                  title: const Text(
                    'الخروج',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'ElMessiri',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _auth.signOut();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacementNamed(
                          context, HomePage.screenRoute);
                    });
                  }),
            ],
          );
        } else {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Stack(
                  children: [
                    Positioned(
                        top: 60,
                        child: Row(
                          children: [
                            Image.asset(
                              "images/logo.png",
                              height: 60,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "إيواء",
                              style: TextStyle(
                                color: Style.brown,
                                fontSize: 28,
                                fontFamily: 'ElMessiri',
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 249, 241, 241),
                ),
              ),
              ListTile(
                  leading: Icon(
                    Icons.login_outlined,
                    color: Style.purpole,
                  ),
                  title: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'ElMessiri',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, Login.screenRoute);
                  }),
              ListTile(
                  leading: Icon(
                    Icons.create,
                    color: Style.purpole,
                  ),
                  title: const Text(
                    'إنشاء حساب جديد ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'ElMessiri',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, Register.screenRoute);
                  }),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Style.purpole,
                ),
                title: const Text(
                  "إضافة حيوان أليف للتبني",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'ElMessiri',
                    fontWeight: FontWeight.w200,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, Login.screenRoute);
                },
              ),
            ],
          );
        }
      }),
    ));
  }
}
