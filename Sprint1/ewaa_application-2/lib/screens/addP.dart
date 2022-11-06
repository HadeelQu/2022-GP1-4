import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import '../widgets/button.dart';
import './continuesAdd.dart';

import '../style.dart';
import '../widgets/fieldAdd.dart';

class AddPets extends StatefulWidget {
  static const String screenRoute = "add_page";

  @override
  State<AddPets> createState() => _AddPetsState();
}

class _AddPetsState extends State<AddPets> {
  TextEditingController _petName = TextEditingController();
  File? imageFile;
  GlobalKey<FormState> formState = new GlobalKey<FormState>();
  var selectedGender;
  var selectedType;
  var type;
  var breedSelected;
  var selectedAge;
  var selectdColor;
  List<dynamic> petType = [];
  List<dynamic> petBreeds = [];
  List<dynamic> petGender = [];
  List<dynamic> petAge = [];
  List<dynamic> petColors = [];

  List<dynamic> breedsList = [];

  var categor;

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
    });
  }

  //--------------uploade image from gallery------------------------------------
  void pickImageGallery() async {
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000);
    setState(() {
      imageFile = File(pickedFile!.path);
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
    // TODO: implement initState
    super.initState();
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

  final _auth = FirebaseAuth.instance;
  var userName = "";
  late User siginUser;
  late ScrollController sc;

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
        });
      }
    } catch (error) {}
  }

  @override
  @override
  Widget build(BuildContext context) {
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
          body: Column(children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  buildSectionTitle(context, "معلومات عامة"),
                  Container(
                    margin: EdgeInsets.only(bottom: 26, left: 26, right: 26),
                    alignment: Alignment.center,
                    height: 200,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Style.textFieldsColor_lightpink,
                    ),
                    child: imageFile == null
                        ? Stack(
                            children: [
                              IconButton(
                                iconSize: 70,
                                icon: Icon(
                                  Icons.add_a_photo,
                                  color: Style.purpole,
                                ),
                                onPressed: () {
                                  uploadeImage(context);
                                },
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                top: 0,
                                right: 0,
                                bottom: 0,
                                left: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                      child: Image.file(
                                    imageFile!,
                                    fit: BoxFit.fill,
                                  )),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    uploadeImage(context);
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Style.buttonColor_pink,
                                          border: Border.all(
                                            width: 2,
                                            color: Style.buttonColor_pink,
                                          ),
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Form(
                    key: formState,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: FileldsAdd("ادخل اسم الحيوان/غير اجباري",
                              _petName, TextInputType.text, (_petName) {
                            if (!_petName.toString().isEmpty) {
                              if (!RegExp(
                                      r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z-_ ]+$')
                                  .hasMatch(
                                      _petName.toString().toLowerCase())) {
                                return "الرجاء ادخال اسم فقط يحتوي علي حروف";
                              }
                            }

                            return null;
                          }, 1, 10),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "الجنس",
                              style: TextStyle(
                                color: Style.black,
                                fontSize: 19,
                              ),
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Expanded(
                              child: RadioListTile(
                                  activeColor: Style.purpole,
                                  contentPadding: EdgeInsets.all(0),
                                  tileColor: Colors.purple.shade50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  value: "ذكر",
                                  groupValue: selectedGender,
                                  title: Text("ذكر"),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: RadioListTile(
                                  activeColor: Style.purpole,
                                  contentPadding: EdgeInsets.all(0),
                                  tileColor: Colors.purple.shade50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  value: "انثى",
                                  groupValue: selectedGender,
                                  title: Text("انثى"),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  }),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FormHelper.dropDownWidget(
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
                              this.breedSelected = null;
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
                        SizedBox(
                          height: 15,
                        ),
                        //--------------Breeds-----------------------------------
                        FormHelper.dropDownWidget(
                          context,
                          "الفصيله",
                          this.breedSelected,
                          this.breedsList,
                          (breed) {
                            setState(() {
                              breedSelected = breed;
                            });
                            print(breedSelected);
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
                        SizedBox(
                          height: 15,
                        ),
                        //--------------colors-----------------------------------
                        FormHelper.dropDownWidget(
                          context,
                          "اللون",
                          this.selectdColor,
                          this.petColors,
                          (Color) {
                            selectdColor = Color;
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
                        SizedBox(
                          height: 15,
                        ),
                        FormHelper.dropDownWidget(
                          context,
                          "العمر",
                          this.selectedAge,
                          this.petAge,
                          (age) {
                            selectedAge = age;
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
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: MyButton(
                      color: Style.buttonColor_pink,
                      title: "التالي",
                      onPeressed: () {
                        if (formState.currentState!.validate()) {
                          var category = petType
                              .where((element) =>
                                  element['id'].toString() ==
                                  selectedType.toString())
                              .toList();

                          var breeds = breedsList
                              .where((element) =>
                                  element['id'].toString() == breedSelected)
                              .toList();

                          var color = petColors
                              .where((element) =>
                                  element['id'].toString() == selectdColor)
                              .toList();
                          var age = petAge
                              .where((element) =>
                                  element['id'].toString() == selectedAge)
                              .toList();
                          var type = petType
                              .where((element) =>
                                  element['id'].toString() == selectedType)
                              .toList();

                          if (selectedGender == null || imageFile == null) {
                            _showErrorDialog("قم باكمال المعلومات");
                          } else {
                            Navigator.pushNamed(
                                context, ContinuesAdd.screenRoute,
                                arguments: {
                                  "name": _petName.text,
                                  "gender": selectedGender,
                                  "type": type[0]['type'],
                                  "breed": breeds[0]['breed'],
                                  "age": age[0]['age'],
                                  "color": color[0]['color'],
                                  "image": imageFile
                                });
                          }
                        } else {
                          _showErrorDialog("قم بتعبئة جميع المعلومات");
                        }
                      },
                      minwidth: 500,
                      circular: 0,
                    ),
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}
