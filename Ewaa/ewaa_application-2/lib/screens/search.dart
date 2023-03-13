import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/listPets.dart';
import 'package:ewaa_application/screens/login.dart';

import 'package:ewaa_application/screens/petInfo.dart';
import 'package:ewaa_application/widgets/bottom_nav.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../style.dart';

class SearchPage extends StatefulWidget {
  static const String screenRoute = "search_page";

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late var addedAt;
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

  GlobalKey<FormState> formState = new GlobalKey<FormState>();
  var selectedGender;
  var selectedType;
  var type;
  var selectedBreed;
  var selectedAge;
  var selectdColor;

  var isLoading = false;
  List<dynamic> searchResults = [];

  List<dynamic> petType = [];
  List<dynamic> petBreeds = [];
  List<dynamic> petGender = [];
  List<dynamic> petAge = [];
  List<dynamic> petColors = [];

  List<dynamic> breedsList = [];

  var categor;

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
  void initState() {
    super.initState();
    sc = new ScrollController();
    getUser();

    this.petGender.add({"id": 1, "gender": "ذكر"});
    this.petGender.add({"id": 2, "gender": "انثى"});
    this.petType.add({"id": 1, "type": "قط"});
    this.petType.add({"id": 2, "type": "كلب"});
    this.petBreeds = [
      {"id": 1, "breed": "السيامي", "parentId": 1},
      {"id": 2, "breed": "الشيرازي", "parentId": 1},
      {"id": 3, "breed": "الهيمالايا", "parentId": 1},
      {"id": 4, "breed": "سكوتش فولد", "parentId": 1},
      {"id": 5, "breed": "اخرى", "parentId": 1},
      {"id": 1, "breed": "بودل", "parentId": 2},
      {"id": 2, "breed": "الهاسكي", "parentId": 2},
      {"id": 3, "breed": "بيتبول", "parentId": 2},
      {"id": 4, "breed": "مالتيز", "parentId": 2},
      {"id": 5, "breed": "اخرى", "parentId": 2},
    ];
    this.petAge = [
      {"id": 1, "age": "صغير"}, //نتاكد
      {"id": 2, "age": "بالغ "},
      {"id": 3, "age": "كبير"},
    ];
    this.petColors = [
      {"id": 1, "color": "ابيض"},
      {"id": 2, "color": "اسود"},
      {"id": 3, "color": "بني"},
      {"id": 4, "color": "برتقالي"},
      {"id": 5, "color": "مختلط"},
      {"id": 6, "color": "رمادي"},
      {"id": 7, "color": "اخرى"},
    ];
  }

  getPets() {
    Query query = FirebaseFirestore.instance
        .collection("pets")
        .where("isAdopted", isEqualTo: false);

    if (selectedGender != null) {
      var gender = petGender
          .where((element) => element['id'].toString() == selectedGender)
          .toList()
          .first['gender'];
      query = query.where('gender', isEqualTo: gender);
    }
    if (selectedType != null) {
      var type = petType
          .where((element) => element['id'].toString() == selectedType)
          .toList()
          .first['type'];
      query = query.where('category', isEqualTo: type);
    }

    if (selectedBreed != null) {
      var breed = breedsList
          .where((element) => element['id'].toString() == selectedBreed)
          .toList()
          .first['breed'];
      query = query.where('breed', isEqualTo: breed);
    }

    if (selectdColor != null) {
      var color = petColors
          .where((element) => element['id'].toString() == selectdColor)
          .toList()
          .first['color'];
      query = query.where('color', isEqualTo: color);
    }

    if (selectedAge != null) {
      var age = petAge
          .where((element) => element['id'].toString() == selectedAge)
          .toList()
          .first['age'];
      query = query.where('age', isEqualTo: age);
    }
    return query.orderBy("addedAt", descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: getProfilePageAppBar(context),
        drawer: listView(),
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSectionTitle(context, "محددات البحث"),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                    tooltip: "إعادة تعيين المحددات",
                    onPressed: () {
                      setState(() {
                        selectedAge = null;
                        selectdColor = null;
                        selectedGender = null;
                        selectedType = null;
                        selectedBreed = null;
                      });
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Style.purpole,
                    )),
              ),
            ],
          ),
          Form(
            key: formState,
            child: Column(
              children: [
                FormHelper.dropDownWidget(
                  context,
                  "الجنس",
                  this.selectedGender,
                  this.petGender,
                  (gender) {
                    setState(() {
                      selectedGender = gender;
                    });
                    print(selectedGender);
                  },
                  (value) {
                    if (value == null) {
                      return " قم بالاختيار";
                    }

                    return null;
                  },
                  optionValue: "id",
                  optionLabel: "gender",
                  borderColor: Style.gray,
                  borderFocusColor: Style.purpole,
                ),

                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: FormHelper.dropDownWidget(
                        context,
                        "الصنف",
                        this.selectedType,
                        this.petType,
                        (type) {
                          setState(() {
                            selectedType = type;
                            print(selectedType);
                            this.breedsList = this
                                .petBreeds
                                .where((breeds) =>
                                    breeds["parentId"].toString() ==
                                    type.toString())
                                .toList();
                            this.selectedBreed = null;
                          });
                        },
                        (value) {
                          if (value == null) {
                            return " قم بالاختيار";
                          }

                          return null;
                        },
                        optionValue: "id",
                        optionLabel: "type",
                        borderColor: Style.gray,
                        borderFocusColor: Style.gray,
                      ),
                    ),
                    //--------------Breeds-----------------------------------

                    Expanded(
                      child: FormHelper.dropDownWidget(
                        context,
                        "الفصيله",
                        this.selectedBreed,
                        this.breedsList,
                        (breed) {
                          setState(() {
                            selectedBreed = breed;
                          });
                          print(selectedBreed);
                        },
                        (value) {
                          if (value == null) {
                            return " قم بالاختيار";
                          }

                          return null;
                        },
                        optionValue: "id",
                        optionLabel: "breed",
                        borderColor: Style.gray,
                        borderFocusColor: Style.purpole,
                      ),
                    )
                  ],
                ),

                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    //--------------colors-----------------------------------
                    Expanded(
                      child: FormHelper.dropDownWidget(
                        context,
                        "اللون",
                        this.selectdColor,
                        this.petColors,
                        (Color) {
                          setState(() {
                            selectdColor = Color;
                          });

                          print(selectdColor);
                        },
                        (value) {
                          if (value == null) {
                            return " قم بالاختيار";
                          }

                          return null;
                        },
                        optionValue: "id",
                        optionLabel: "color",
                        borderColor: Style.gray,
                        borderFocusColor: Style.purpole,
                      ),
                    ),
                    Expanded(
                      child: FormHelper.dropDownWidget(
                        context,
                        "العمر",
                        this.selectedAge,
                        this.petAge,
                        (age) {
                          setState(() {
                            selectedAge = age;
                          });

                          print(selectedAge);
                        },
                        (value) {
                          if (value == null) {
                            return " قم بالاختيار";
                          }

                          return null;
                        },
                        optionValue: "id",
                        optionLabel: "age",
                        borderColor: Style.gray,
                        borderFocusColor: Style.purpole,
                      ),
                    )
                  ],
                )
                // ,
                //
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 25),
                //   child: MyButton(
                //     color: Style.buttonColor_pink,
                //     title: "بحث",
                //     onPeressed: () {
                //           getPets();
                //     },
                //     minwidth: 500,
                //     circular: 0,
                //   ),
                // )
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getPets(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // List<dynamic> searchResults=snapshot.data!.docs.where((document)=>checkFilter(document)).toList();
                // var searchResults=snapshot.data!.docs;

                if (snapshot.hasError) return Text("يوجد خطأ");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Style.purpole,
                      // backgroundColor: Style.purpole,
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
                            "لا توجد نتائج مطابقة للبحث",
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
                    children: snapshot.data!.docs.map((document) {
                      if (document['petName'] == "") {
                        petname = document['category'];
                      } else {
                        petname = document['petName'];
                      }
                      Timestamp uplodedAt = document['addedAt'];
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
                                        borderRadius: BorderRadius.circular(14),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            document['image'],
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
                                                MainAxisAlignment.spaceBetween,
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
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  document['breed'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Style.black,
                                                    fontFamily: 'ElMessiri',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  document['gender'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Style.black,
                                                    fontFamily: 'ElMessiri',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'العمر : ' + document['age'],
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
                                            margin: EdgeInsets.only(right: 80),
                                            child: MyButton2(
                                                color: Style.buttonColor_pink,
                                                title: "عرض الحيوان الأليف",
                                                onPeressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PetInfo(
                                                        petId:
                                                            document['petId'],
                                                        owner:
                                                            document['ownerId'],
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
          )
        ]),
      ),
    );
  }
}
