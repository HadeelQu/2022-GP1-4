import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/editPetInfo.dart';
import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../style.dart';
import '../widgets/button.dart';

class History extends StatefulWidget {
  static const String screenRoute = "history_page";

  @override
  State<History> createState() => _History();
}

class _History extends State<History> {
  final title;
  String _selectedType = "حيوانات تبنيتها";
  _History({this.title = ''});

  final _auth = FirebaseAuth.instance;
  late ScrollController sc;
  bool isLoading = false;
  var petname;
  getAllMyPets() {
    if (_selectedType == "حيوانات تبنيتها") {
      return FirebaseFirestore.instance
          .collection("pets")
          .where('ownerId', isEqualTo: _auth.currentUser!.uid)
          .where('isAdopted', isEqualTo: true)
          .orderBy("addedAt", descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection("pets")
          .where('old_owner', isEqualTo: _auth.currentUser!.uid)
          .where('isAdopted', isEqualTo: true)
          .orderBy("addedAt", descending: true)
          .snapshots();
    }
  }

  Widget typeChip(String type) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 38),
        decoration: BoxDecoration(
            color: type == _selectedType
                ? Style.buttonColor_pink
                : Style.textFieldsColor_lightpink,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Style.textFieldsColor_lightpink)),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
                fontFamily: 'ElMessiri',
                color: type == _selectedType ? Colors.white : Style.purpole),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            iconTheme: IconThemeData(color: Style.black, size: 28),
            toolbarHeight: 75,
            title: Row(
              children: [
                SizedBox(
                  width: 83,
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
                    Navigator.pop(context);
                  }),
            ]),
        drawer: listView(),
        body: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(right: 20),
              child: Text("عملياتي السابقة في التبني",
                  style: Theme.of(context).textTheme.headline4),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  typeChip("حيوانات تبنيتها"),
                  SizedBox(
                    width: 10,
                  ),
                  typeChip("حيوانات تم تبنيها مني"),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getAllMyPets(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) return const Text("يوجد خطأ");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 155, 140, 181)),
                            backgroundColor: Style.purpole,
                          )),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Container(
                          color: Colors.blue,
                          child: Text(
                            "لا توجد حيوانات متوفرة",
                            style: TextStyle(color: Colors.black),
                          )),
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
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.only(left: 5, right: 5),
                      children: snapshot.data!.docs.map((doucument) {
                        if (doucument['petName'] == "") {
                          petname = doucument['category'];
                        } else {
                          petname = doucument['petName'];
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 0.9 * size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Style.textFieldsColor_lightpink
                                        .withOpacity(0.4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.only(right: 8),
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
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 12.0, top: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      petname,
                                                      style: TextStyle(
                                                        color: Style.black,
                                                        fontFamily: 'ElMessiri',
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                  ),
                                                ],
                                              ),
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
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  height: 36,
                                                  margin: const EdgeInsets.only(
                                                    right: 8.0,
                                                    bottom: 8.0,
                                                    left: 8.0,
                                                  ),
                                                  child: MyButton2(
                                                      color: Style
                                                          .buttonColor_pink,
                                                      title:
                                                          "عرض الحيوان الأليف",
                                                      onPeressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
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
      ),
    );
  }
}
