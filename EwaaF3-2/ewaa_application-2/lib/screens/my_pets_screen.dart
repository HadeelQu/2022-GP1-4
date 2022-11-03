import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/editPetInfo.dart';
import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../style.dart';
import '../widgets/button.dart';

class MyPetsPage extends StatefulWidget {
  static const String screenRoute = "mypets_page";

  @override
  State<MyPetsPage> createState() => _MyPetsPage();
}

class _MyPetsPage extends State<MyPetsPage> {
  final title;
  _MyPetsPage({this.title = ''});

  final _auth = FirebaseAuth.instance;
  late ScrollController sc;
  bool isLoading = false;
  var petname;
  getAllMyPets() {
    return FirebaseFirestore.instance
        .collection("pets")
        .where('ownerId', isEqualTo: _auth.currentUser!.uid)
        .orderBy("addedAt", descending: true)
        .snapshots();
  }

  deleteMyPet(petId) async {
    await FirebaseFirestore.instance.collection("pets").doc(petId).delete();

    Fluttertoast.showToast(
        msg: " تم الحذف بنجاح ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Style.textFieldsColor_lightpink,
        textColor: Style.purpole,
        fontSize: 16.0);
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
              height: 19,
            ),
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(right: 20),
              child: Text("حيواناتي الأليفة المضافة",
                  style: Theme.of(context).textTheme.headline4),
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
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (con) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  'هل تريد حذف الحيوان',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Style
                                                                        .black,
                                                                    fontFamily:
                                                                        'ElMessiri',
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator
                                                                          .pop(
                                                                              con);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              5),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Style
                                                                            .buttonColor_pink,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'إلغاء',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontFamily:
                                                                              'ElMessiri',
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            true;
                                                                      });
                                                                      await deleteMyPet(
                                                                          doucument[
                                                                              'petId']);
                                                                      Navigator
                                                                          .pop(
                                                                              con);
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              5),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Style
                                                                            .buttonColor_pink,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'حذف',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontFamily:
                                                                              'ElMessiri',
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      222,
                                                                      10,
                                                                      10),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: const Icon(
                                                              Icons.delete,
                                                              size: 22,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                      SizedBox(width: 20),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      EditPetInfo(
                                                                petId: doucument[
                                                                    'petId'],
                                                                owner: doucument[
                                                                    'ownerId'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      157,
                                                                      179,
                                                                      191),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: const Icon(
                                                              Icons.edit,
                                                              size: 22,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                      SizedBox(width: 8.0),
                                                    ],
                                                  )
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
