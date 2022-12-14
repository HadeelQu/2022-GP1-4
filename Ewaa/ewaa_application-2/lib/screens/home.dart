import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:ewaa_application/catPersonailty.dart';
import 'package:ewaa_application/dogPersonailty.dart';
import 'package:ewaa_application/screens/listPets.dart';
import 'package:ewaa_application/screens/login.dart';

import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/screens/search.dart';
import 'package:ewaa_application/widgets/bottom_nav.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
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

  var pets_snapshot = FirebaseFirestore.instance
      .collection("pets")
      .orderBy("likes_count", descending: true)
      .limit(10)
      .snapshots();

  prepareData() async {
    final _user = _auth.currentUser;
    var data = {};
    if (_user != null) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(_user.uid)
          .get()
          .then((doc) {
        var userData = doc.data();
        var likedPets = userData!["likedPets"];
        data["liked_id"] = likedPets;

        FirebaseFirestore.instance.collection("pets").get().then((pets) async {
          var petsData = {};
          for (var pet in pets.docs) {
            petsData[pet.get("petId")] = pet.get("genralPersonailty");
          }
          data["personality"] = petsData;
          var dbasics_personality = [];

          DogPersonailty.Personailty.forEach((element) {
            dbasics_personality.add(element.label);
          });

          var cbasics_personality = [];

          CatPersonailty.Personailty.forEach((element) {
            cbasics_personality.add(element.label);
          });

          var all_personalities = [];
          all_personalities.addAll(cbasics_personality);
          all_personalities.addAll(dbasics_personality);
          var distinct_list = all_personalities.toSet().toList();

          data["basics_personality"] = distinct_list;

          var dio = Dio();
          await dio
              .post(
            'http://10.0.2.2:5000/Recommender',
            data: data,
          )
              .then((value) {
            // var r=jsonDecode(response.data);
            print("response:" + value.data.toString());
            var similarities = value.data;
            var featured_pets = similarities['similarity_pets'];

            setState(() {
              pets_snapshot = FirebaseFirestore.instance
                  .collection("pets")
                  .where("petId", whereIn: featured_pets)
                  .limit(10)
                  .snapshots();
            });
          }).catchError((e) {
            print("errorrrrr:" + e.toString());
            setState(() {
              pets_snapshot = FirebaseFirestore.instance
                  .collection("pets")
                  .orderBy("likes_count", descending: true)
                  .limit(10)
                  .snapshots();
            });
          });

          // print(data.toString());
        });
      });
    }
  }

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
    prepareData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // getPetslimit() {
    //   return FirebaseFirestore.instance
    //       .collection("pets")
    //       .orderBy("likes_count", descending: true)
    //       .limit(10)
    //       .snapshots();
    // }

    return SafeArea(
      child: Scaffold(
        appBar: getCustomAppBar(context),
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
                      child: Text("???????? ?????????? ?????????? ..",
                          style: Theme.of(context).textTheme.headline4),
                    ),
                    Container(
                      child: Text(
                        " ???????????? ",
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
                InkWell(
                  onTap: () => {
                    Navigator.pushReplacementNamed(
                        context, SearchPage.screenRoute)
                  },
                  child: Container(
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
                            "???? ???????? ???? ?????????? ???????? ?? ????????????????",
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
                            Navigator.pushReplacementNamed(
                                context, SearchPage.screenRoute);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 26, left: 26, right: 26),
                  child: Text(
                    "??????????????????",
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
                              arguments: "??????");
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
                              arguments: "????????");
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
                              arguments: "????????");
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      " ??????",
                      style: TextStyle(
                        color: Style.purpole.withOpacity(0.8),
                        fontFamily: 'ElMessiri',
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      " ????????",
                      style: TextStyle(
                        color: Style.purpole.withOpacity(0.8),
                        fontFamily: 'ElMessiri',
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      " ????????",
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
                    "?????????????????? ????????????????",
                    style: TextStyle(
                      color: Style.purpole.withOpacity(0.8),
                      fontFamily: 'ElMessiri',
                      fontSize: 20,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: pets_snapshot,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("???????? ??????"),
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
                                "???? ???????? ?????????????? ?????????? ????????????",
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
                                                '?????????? : ' + doucument['age'],
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
                                              '?????????? ????????????',
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
        bottomNavigationBar: BottomNav(selectedPage: HomePage.screenRoute),
      ),
    );
  }
}
