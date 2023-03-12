import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/bottom_nav.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);
  static const String screenRoute = "favourites_page";

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  var petname;
  late var addedAt;

  var _auth = FirebaseAuth.instance;

  getPets() {
    return FirebaseFirestore.instance
        .collection("pets")
        .where("likedUsers", arrayContains: _auth.currentUser?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
            appBar: getCustomAppBar(context),
            drawer: listView(),
            body: Column(
              children: [
                buildSectionTitle(context, "حيواناتي المفضلة"),
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
                                  "لاتوجد حيوانات في المفضلة",
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
                            return Stack(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 350,
                                          height: 103,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Style
                                                .textFieldsColor_lightpink
                                                .withOpacity(0.4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                width: 90,
                                                height: 90,
                                                margin:
                                                    EdgeInsets.only(right: 8),
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
                                                            fontFamily:
                                                                'ElMessiri',
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        Text(
                                                          addedAt.toString(),
                                                          style: TextStyle(
                                                            color: Style.black,
                                                            fontFamily:
                                                                'ElMessiri',
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
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Style.black,
                                                              fontFamily:
                                                                  'ElMessiri',
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            doucument['gender'],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Style.black,
                                                              fontFamily:
                                                                  'ElMessiri',
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            'العمر : ' +
                                                                doucument[
                                                                    'age'],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Style.black,
                                                              fontFamily:
                                                                  'ElMessiri',
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ]),
                                                    Container(
                                                      height: 36,
                                                      margin: EdgeInsets.only(
                                                          right: 80),
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
                                ),
                                doucument['isAdopted'] != null &&
                                        doucument['isAdopted'] == true
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                Style.buttonColor_pink,
                                            child: Text(
                                              "تم التبني",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      )
                                    : const SizedBox(),
                              ],
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
            bottomNavigationBar: BottomNav(
              selectedPage: FavouritesPage.screenRoute,
            )));
  }
}
