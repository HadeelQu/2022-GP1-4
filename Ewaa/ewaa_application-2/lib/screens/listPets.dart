import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/screens/search.dart';
import 'package:ewaa_application/widgets/bottom_nav.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:flutter/material.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../style.dart';
import '../widgets/button.dart';

class ListPetsPage extends StatefulWidget {
  static const String screenRoute = "listPets_page";

  @override
  State<ListPetsPage> createState() => _ListPetsPage();
}

class _ListPetsPage extends State<ListPetsPage> {
  final title;
  _ListPetsPage({this.title = ''});

  final _auth = FirebaseAuth.instance;
  late ScrollController sc;
  var petname;
  late var addedAt;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    getPets() {
      if (args as String == "قطط") {
        return FirebaseFirestore.instance
            .collection("pets")
            .where("category", isEqualTo: "قط")
            .where("isAdopted", isEqualTo: false)
            .orderBy("addedAt", descending: true)
            .snapshots();
      } else if (args as String == "كلاب") {
        return FirebaseFirestore.instance
            .collection("pets")
            .where("category", isEqualTo: "كلب")
            .where("isAdopted", isEqualTo: false)
            .orderBy("addedAt", descending: true)
            .snapshots();
      } else if (args as String == "الكل") {
        return FirebaseFirestore.instance
            .collection("pets")
            .where("isAdopted", isEqualTo: false)
            .orderBy("addedAt", descending: true)
            .snapshots();
      }
    }

    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent, //transparent
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
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.arrow_forward_sharp,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, HomePage.screenRoute);
                  }),
            ]),
        drawer: listView(),
        body: Column(
          children: [
            SizedBox(
              height: 19,
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Text(args as String,
                      style: Theme.of(context).textTheme.headline4),
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
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, SearchPage.screenRoute);
                },
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
                      onPressed: () {
                        Navigator.pushNamed(context, SearchPage.screenRoute);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 350,
              height: 40,
              child: Text(
                "الحيوانات المتوفرة",
                style: TextStyle(
                  color: Style.purpole.withOpacity(0.8),
                  fontFamily: 'ElMessiri',
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getPets(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) return Text("يوجد خطأ");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
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
                    return ListView(
                      scrollDirection: Axis.vertical,
                      children: snapshot.data!.docs.map((doucument) {
                        if (doucument['petName'] == "") {
                          petname = doucument['category'];
                        } else {
                          petname = doucument['petName'];
                        }
                        Timestamp uplodedAt = doucument['addedAt'];
                        var uplodedAtDate = uplodedAt.toDate();
                        addedAt =
                            '${uplodedAtDate.year}-${uplodedAtDate.month}-${uplodedAtDate.day}';
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 350,
                                  height: 103,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Style.textFieldsColor_lightpink
                                        .withOpacity(0.4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              doucument['image'],
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 230,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  petname,
                                                  style: TextStyle(
                                                    color: Style.black,
                                                    fontFamily: 'ElMessiri',
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                Text(
                                                  addedAt.toString(),
                                                  style: TextStyle(
                                                    color: Style.black,
                                                    fontFamily: 'ElMessiri',
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    doucument['breed'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Style.black,
                                                      fontFamily: 'ElMessiri',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    doucument['gender'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Style.black,
                                                      fontFamily: 'ElMessiri',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'العمر : ' +
                                                        doucument['age'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Style.black,
                                                      fontFamily: 'ElMessiri',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ]),
                                            Container(
                                              height: 36,
                                              margin:
                                                  EdgeInsets.only(right: 80),
                                              child: MyButton2(
                                                  color: Style.buttonColor_pink,
                                                  title: "عرض الحيوان الأليف",
                                                  onPeressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PetInfo(
                                                          petId: doucument[
                                                              'petId'],
                                                          owner: doucument[
                                                              'ownerId'],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNav(),
      ),
    );
  }
}
