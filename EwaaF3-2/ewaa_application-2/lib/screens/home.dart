import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/listPets.dart';
import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:flutter/material.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../style.dart';

class HomePage extends StatefulWidget {
  static const String screenRoute = "home_page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  var userName = "";
  late User siginUser;
  late ScrollController sc;
  var petname;
  bool loading = false;

  //  controller: sc,

  getUser() async {
    try {
      userName = "";
      final _user = _auth.currentUser;
      if (_user != null) {
        siginUser = _user;
        final DocumentSnapshot info = await FirebaseFirestore.instance
            .collection('Users')
            .doc(siginUser.uid)
            .get();

        setState(() {
          userName = info.get('userNamae');
          loading = true;
        });
      }
    } catch (error) {
      loading = false;
    }
  }

  @override
  void initState() {
    sc = new ScrollController();
    getUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    getPetslimit() {
      return FirebaseFirestore.instance
          .collection("pets")
          .orderBy("addedAt", descending: true)
          .limit(5)
          .snapshots();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Style.black, size: 28),
          toolbarHeight: 75,
          title: Row(
            children: [
              IconButton(
                padding: EdgeInsets.only(left: 20),
                icon: Icon(
                  Icons.person_sharp,
                  size: 30,
                ),
                onPressed: () {
                  if (_auth.currentUser == null) {
                    Navigator.pushNamed(context, Register.screenRoute);
                  } else {
                    Navigator.pushNamed(context, ProfilePage.screenRoute);
                  }
                },
              ),
              SizedBox(
                width: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/logo.png",
                    height: 35,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "إيواء",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ],
              ),
            ],
          ),
        ),
        drawer: listView(),
        body: Column(children: [
          Expanded(
            child: ListView(
              shrinkWrap: true, // use it
              scrollDirection: Axis.vertical,
              children: [
                SizedBox(
                  height: 19,
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Text("إبدأ رحلتك وتبنى ..",
                          style: Theme.of(context).textTheme.headline4),
                    ),
                    Container(
                      child: Text(
                        " مرحبًا ",
                        style: TextStyle(
                          color: Style.purpole,
                          fontSize: 19,
                          fontFamily: 'ElMessiri',
                        ),
                      ),
                    ),
                    !loading
                        ? Center(
                            child: Container(
                                width: 0,
                                height: 0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 155, 140, 181)),
                                  backgroundColor: Style.purpole,
                                )),
                          )
                        : Container(
                            child: Text(
                              userName,
                              style: TextStyle(
                                color: Style.purpole,
                                fontSize: 18,
                                fontFamily: 'ElMessiri',
                              ),
                            ),
                          ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 26, left: 26, right: 26),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Style.textFieldsColor_lightpink,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(
                          "هل تبحث عن حيوان معين ؟ استخدمني",
                          style: TextStyle(
                            color: Style.purpole.withOpacity(0.8),
                            fontFamily: 'ElMessiri',
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_alt_sharp,
                          size: 30,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 26, left: 26, right: 26),
                  child: Text(
                    "التصنيفات",
                    style: TextStyle(
                      color: Style.purpole.withOpacity(0.8),
                      fontFamily: 'ElMessiri',
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Style.gray.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        child: Image.asset(
                          "images/Cat.png",
                          height: 80,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, ListPetsPage.screenRoute,
                              arguments: "قطط");
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Style.gray.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        child: Image.asset(
                          "images/Dog.png",
                          height: 80,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, ListPetsPage.screenRoute,
                              arguments: "كلاب");
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Style.gray.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        child: Image.asset(
                          "images/pet.png",
                          height: 80,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, ListPetsPage.screenRoute,
                              arguments: "الكل");
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      " قطط",
                      style: TextStyle(
                        color: Style.purpole.withOpacity(0.8),
                        fontFamily: 'ElMessiri',
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      " كلاب",
                      style: TextStyle(
                        color: Style.purpole.withOpacity(0.8),
                        fontFamily: 'ElMessiri',
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      " الكل",
                      style: TextStyle(
                        color: Style.purpole.withOpacity(0.8),
                        fontFamily: 'ElMessiri',
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 29,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 26, left: 26, right: 26),
                  width: 350,
                  height: 27,
                  child: Text(
                    "حيوانات متوفرة",
                    style: TextStyle(
                      color: Style.purpole.withOpacity(0.8),
                      fontFamily: 'ElMessiri',
                      fontSize: 20,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: getPetslimit(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("يوجد خطأ"),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 200,
                        width: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 155, 140, 181)),
                          ),
                        ),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Style.textFieldsColor_lightpink,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                "لا توجد حيوانات أليفة متوفرة",
                                style: TextStyle(
                                  color: Style.purpole.withOpacity(0.8),
                                  fontFamily: 'ElMessiri',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox(
                        height: 205,
                        child: Center(
                          child: ListView(
                            shrinkWrap: true, // use it
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data!.docs.map((doucument) {
                              if (doucument['petName'] == "") {
                                petname = doucument['category'];
                              } else {
                                petname = doucument['petName'];
                              }
                              return Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Card(
                                  color: Color.fromARGB(255, 255, 247, 247),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: 170,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                doucument['image'],
                                              ),
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                      Text(
                                        petname,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Style.black,
                                          fontFamily: 'ElMessiri',
                                          fontSize: 18,
                                        ),
                                      ),
                                      Container(
                                        width: 170,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                doucument['breed'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Style.black,
                                                  fontFamily: 'ElMessiri',
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                doucument['gender'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Style.black,
                                                  fontFamily: 'ElMessiri',
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'العمر : ' + doucument['age'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Style.black,
                                                  fontFamily: 'ElMessiri',
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                color: Colors.black
                                                    .withOpacity(0.3)),
                                          ),
                                        ),
                                        width: 170,
                                        child: TextButton(
                                            child: Text(
                                              'اكتشف المزيد',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Style.purpole,
                                                fontFamily: 'ElMessiri',
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PetInfo(
                                                    petId: doucument['petId'],
                                                    owner: doucument['ownerId'],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(238, 252, 249, 249),
          currentIndex: 0,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Style.buttonColor_pink,
          unselectedItemColor: Color.fromARGB(189, 116, 115, 115),
          unselectedLabelStyle: TextStyle(fontFamily: "ElMessiri"),
          selectedLabelStyle: TextStyle(fontFamily: "ElMessiri"),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "الرئيسية",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "البحث",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "المفضلة",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: "الإشعارات",
            ),
          ],
          onTap: (value) {
            if (0 == value) {
              Navigator.pushReplacementNamed(context, HomePage.screenRoute);
            } else if (1 == value) {
              // Navigator.pushReplacementNamed(context, .screenRoute);
            } else if (2 == value) {
              //Navigator.pushReplacementNamed(context, .screenRoute);
            } else if (3 == value) {
              // Navigator.pushReplacementNamed(context, .screenRoute);
            }
          },
        ),
      ),
    );
  }
}
