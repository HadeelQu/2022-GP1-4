import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/catPersonailty.dart';
import 'package:ewaa_application/dogPersonailty.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../style.dart';
import '../widgets/button.dart';
import '../widgets/fieldAdd.dart';

class ContinuesEdit extends StatefulWidget {
  final String petId;
  final String name;
  final String gender;
  final String type;
  final String breed;
  final String age;
  final String color;
  final image;

  ContinuesEdit(
      {required this.petId,
      required this.name,
      required this.gender,
      required this.type,
      required this.breed,
      required this.age,
      required this.color,
      required this.image});

  @override
  State<ContinuesEdit> createState() => _ContinuesEdit();
}

class _ContinuesEdit extends State<ContinuesEdit> {
  TextEditingController _petName = TextEditingController();
  TextEditingController _healthProfileCont = TextEditingController();
  TextEditingController _reasonsOfAdoption = TextEditingController();
  TextEditingController _supplies = TextEditingController();
  TextEditingController _personailty = TextEditingController();

  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  var selectedIncolustion;
  var selectedIncolustionId;

  var selectedNeutering;
  var selectedNeuteringId;

  var selectedHealthPassport;
  var selectedHealthPassportId;

  var selectedHealthProfile;
  var selectedHealthProfileId;

  var _petSelectedList = [];

  var petPersonailty = [];
  var petPersonailty2 = [];

  var GenralpetPersonailty = [];

  //bool selected = false;

  bool _isloading = false;
  bool _isloading2 = false;

  String? url;

  late var incolustion;
  late var neutering;
  late var healthPassport;
  late var healthProfile;
  late var healthProfileCont;
  late var reasonsOfAdoption;
  late var supplies;
  late var petSelectedList;
  late var anotherPersonailty;
  late var ActupetBreed;

  final _auth = FirebaseAuth.instance;
  late User siginUser;

  void getData() async {
    try {
      final _user = _auth.currentUser;
      if (_user != null) {
        siginUser = _user;
        final DocumentSnapshot petInfo = await FirebaseFirestore.instance
            .collection('pets')
            .doc(widget.petId)
            .get();

        setState(() {
          ActupetBreed = petInfo.get("breed");

          incolustion = petInfo.get("incolustion");
          neutering = petInfo.get("Neutering");
          healthPassport = petInfo.get("healthPassport");
          healthProfile = petInfo.get("healthProfile");
          healthProfileCont = petInfo.get("nameOfHospital");
          _healthProfileCont.text = healthProfileCont;
          reasonsOfAdoption = petInfo.get("reasonsOfAdoption");
          _reasonsOfAdoption.text = reasonsOfAdoption;
          anotherPersonailty = petInfo.get("anotherPersonailty");
          _personailty.text = anotherPersonailty;
          print("another==" + anotherPersonailty);

          supplies = petInfo.get("supplies");
          _supplies.text = supplies;

          petSelectedList = petInfo.get("personalites");

          if (ActupetBreed == widget.breed) {
            _petSelectedList = petSelectedList;
            if (petSelectedList[0] != "") _petSelectedList.add("اخرى");
            if (anotherPersonailty != null && anotherPersonailty != "") {
              _personailty.text = anotherPersonailty;
              print("another==" + anotherPersonailty);
            }
          } else {
            _petSelectedList = [];
            _petSelectedList.add("");
          }

          //_personailty.text = petSelectedList[0];

          selectedIncolustion = incolustion;
          selectedNeutering = neutering;
          selectedHealthPassport = healthPassport;
          selectedHealthProfile = healthProfile;

          if (selectedIncolustion.toString() == "نعم")
            selectedIncolustionId = 1;
          if (selectedIncolustion.toString() == "لا") selectedIncolustionId = 2;

          if (selectedNeutering.toString() == "نعم") selectedNeuteringId = 1;
          if (selectedNeutering.toString() == "لا") selectedNeuteringId = 2;

          if (selectedHealthPassport.toString() == "نعم")
            selectedHealthPassportId = 1;
          if (selectedHealthPassport.toString() == "لا")
            selectedHealthPassportId = 2;

          if (selectedHealthProfile.toString() == "نعم")
            selectedHealthProfileId = 1;
          if (selectedHealthProfile.toString() == "لا")
            selectedHealthProfileId = 2;

          _isloading = true;
        });
      }
    } catch (error) {
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

  //--------------initState------------------------------------
  @override
  void initState() {
    // TODO: implement initState
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

  textWidget(lable) {
    return Text(
      lable,
      style: TextStyle(
          color: Style.purpole, fontFamily: 'ElMessiri', fontSize: 15),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    GenralpetPersonailty = [];
    for (var i = 0; i < petPersonailty.length; i++) {
      print(petPersonailty[i].label);
      GenralpetPersonailty.add(petPersonailty[i].label);
    }
    GenralpetPersonailty.remove("اخرى");

    print(GenralpetPersonailty);

    update() async {
      try {
        if (_auth != null) {
          siginUser = _auth.currentUser!;
          setState(() {
            _isloading2 = true;
          });
          final uId = siginUser.uid;
          final petID = widget.petId;

          final DocumentSnapshot check = await FirebaseFirestore.instance
              .collection('pets')
              .doc(widget.petId)
              .get();
          var checkImage = check.get("image");

          if (_personailty.text.isEmpty && !_petSelectedList.contains("اخرى")) {
            setState(() {
              petSelectedList[0] = "";
            });
          }
          if (_personailty.text.isNotEmpty &&
              _petSelectedList.contains("اخرى")) {
            setState(() {
              petSelectedList[0] = _personailty.text;
            });
          }

          if (widget.image == checkImage) {
            await FirebaseFirestore.instance
                .collection("pets")
                .doc(petID)
                .update({
              "petId": petID,
              "petName": widget.name,
              "gender": widget.gender,
              "category": widget.type,
              "breed": widget.breed,
              "color": widget.color,
              "age": widget.age,
              "incolustion": selectedIncolustion,
              "Neutering": selectedNeutering,
              "healthPassport": selectedHealthPassport,
              "healthProfile": selectedHealthProfile,
              "nameOfHospital": _healthProfileCont.text,
              "reasonsOfAdoption": _reasonsOfAdoption.text,
              "supplies": _supplies.text,
              "personalites": _petSelectedList,
              "anotherPersonailty": _personailty.text,
              "genralPersonailty": GenralpetPersonailty,
            });
          } else {
            final imagePet = FirebaseStorage.instance
                .ref()
                .child("petsImage")
                .child(petID + "jpg");

            // Delete the file
            await imagePet.delete();

            await imagePet.putFile(widget.image);

            imagePet.getDownloadURL().then((value) {});

            url = await imagePet.getDownloadURL();
            await FirebaseFirestore.instance
                .collection("pets")
                .doc(petID)
                .update({
              "petId": petID,
              "petName": widget.name,
              "gender": widget.gender,
              "category": widget.type,
              "breed": widget.breed,
              "color": widget.color,
              "age": widget.age,
              "incolustion": selectedIncolustion,
              "Neutering": selectedNeutering,
              "healthPassport": selectedHealthPassport,
              "healthProfile": selectedHealthProfile,
              "nameOfHospital": _healthProfileCont.text,
              "reasonsOfAdoption": _reasonsOfAdoption.text,
              "supplies": _supplies.text,
              "anotherPersonailty": _personailty.text,
              "personalites": _petSelectedList,
              "image": url,
              "genralPersonailty": GenralpetPersonailty,
            });
          }

          //update pet name i all request
          var batch = FirebaseFirestore.instance.batch();

          FirebaseFirestore.instance
              .collection("adoption_requests")
              .where("pet_id", isEqualTo: widget.petId)
              .get()
              .then((requests) {
            for (var request in requests.docs) {
              batch.update(request.reference, {"petName": widget.name});
            }
            batch.commit();
          });

          Fluttertoast.showToast(
              msg: " تم التحديث بنجاح ",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Style.textFieldsColor_lightpink,
              textColor: Style.purpole,
              fontSize: 16.0);
          Navigator.pushNamed(context, HomePage.screenRoute);
        }
      } catch (error) {
        print(error.toString());
        print("error to update");
        setState(() {
          _isloading2 = false;
        });
      }
    }

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
    }

    if (widget.type == "قط") {
      if (widget.breed == "اخرى") {
        petPersonailty = CatPersonailty.Personailty.getRange(0, 9).toList();
      } else {
        petPersonailty = CatPersonailty.Personailty.where((element) =>
                element.breeds == widget.breed || element.breeds == "الكل")
            .toList();
      }
    } else {
      if (widget.breed == "اخرى") {
        petPersonailty = DogPersonailty.Personailty.getRange(0, 9).toList();
      } else {
        petPersonailty = DogPersonailty.Personailty.where((element) =>
                element.breeds == widget.breed || element.breeds == "الكل")
            .toList();
      }
    }
    addAnotherPer() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: FileldsAdd("الشخصية", _personailty, TextInputType.text, (value) {
          if (value.isEmpty) {
            return "الرجاء اكمال بيانات الشخصيه";
          }
          if (!RegExp(r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z-_ ]+$')
              .hasMatch(value)) {
            return "الرجاء ادخال اسم فقط يحتوي علي حروف";
          }
          // print(value);

          return null;
        }, 1, 40),
      );
    }

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
                      Navigator.pop(context);
                    }),
              ]),
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
                      shrinkWrap: true, // use it
                      scrollDirection: Axis.vertical,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        buildSectionTitle(context, "معلومات صحية"),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 26, right: 26),
                          child: Row(
                            children: [
                              Text(
                                "هل هو مطعم",
                                style: TextStyle(
                                  color: Style.black,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                width: 45,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "لا",
                                    groupValue: selectedIncolustion,
                                    title: Text("لا"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedIncolustion = value;
                                        selectedIncolustionId = 2;
                                      });
                                    }),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "نعم",
                                    groupValue: selectedIncolustion,
                                    title: Text("نعم"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedIncolustion = value;
                                        selectedIncolustionId = 1;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 26, right: 26),
                          child: Row(
                            children: [
                              Text(
                                "التعقيم:",
                                style: TextStyle(
                                  color: Style.black,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                width: 76,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "لا",
                                    groupValue: selectedNeutering,
                                    title: Text("لا"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedNeutering = value;
                                        selectedNeuteringId = 2;
                                      });
                                    }),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "نعم",
                                    groupValue: selectedNeutering,
                                    title: Text("نعم"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedNeutering = value;
                                        selectedNeuteringId = 1;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 26, right: 26),
                          child: Row(
                            children: [
                              Text(
                                "هل له جواز صحي:",
                                style: TextStyle(
                                  color: Style.black,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "لا",
                                    groupValue: selectedHealthPassport,
                                    title: Text("لا"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHealthPassport = value;
                                        selectedHealthPassportId = 2;
                                      });
                                    }),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "نعم",
                                    groupValue: selectedHealthPassport,
                                    title: Text("نعم"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHealthPassport = value;
                                        selectedHealthPassportId = 1;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 26, right: 26),
                          child: Row(
                            children: [
                              Text(
                                "هل له ملف صحي",
                                style: TextStyle(
                                  color: Style.black,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "لا",
                                    groupValue: selectedHealthProfile,
                                    title: Text("لا"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHealthProfile = value;
                                        selectedHealthProfileId = 2;
                                        print(selectedHealthProfile);
                                      });
                                    }),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RadioListTile(
                                    activeColor: Style.purpole,
                                    contentPadding: EdgeInsets.all(0),
                                    tileColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    value: "نعم",
                                    groupValue: selectedHealthProfile,
                                    title: Text("نعم"),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHealthProfile = value;
                                        selectedHealthProfileId = 1;
                                        print(selectedHealthProfile);
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),

                        //===============================================
                        Form(
                          key: formState,
                          child: Column(children: [
                            SizedBox(
                              height: 15,
                            ),
                            selectedHealthProfile == "نعم"
                                ? Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    child: FileldsAdd(
                                        "اسم العياده",
                                        _healthProfileCont,
                                        TextInputType.text, (value) {
                                      if (value.isEmpty) {
                                        return "الرجاء ادخال اسم العياده";
                                      }
                                      if (!RegExp(
                                              r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z-_ ]+$')
                                          .hasMatch(value)) {
                                        return "الرجاء ادخال اسم فقط يحتوي علي حروف";
                                      }
                                      return null;
                                    }, 1, 15),
                                  )
                                : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            buildSectionTitle(context, "القصة"),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textWidget("سبب العرض للتبني/غيراجباري"),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FileldsAdd(
                                      "سبب عرض التبني",
                                      _reasonsOfAdoption,
                                      TextInputType.text, (value) {
                                    return null;
                                  }, 5, 100),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            buildSectionTitle(
                              context,
                              "المستلزمات /الاحتياجات",
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textWidget(
                                      "المستلزمات و الاحتياجات/غير اجباريه"),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FileldsAdd("اكتب مايحتاجه حيوانك الاليف",
                                      _supplies, TextInputType.text, (value) {
                                    return null;
                                  }, 5, 50),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            buildSectionTitle(
                              context,
                              "الشخصيه",
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                verticalDirection: VerticalDirection.down,
                                runSpacing: 8,
                                direction: Axis.horizontal,
                                children: petPersonailty
                                    .map((chip) => FilterChip(
                                          pressElevation: 17,
                                          selected: _petSelectedList
                                              .contains(chip.label),
                                          onSelected: (value) {
                                            setState(() {
                                              if (value) {
                                                _petSelectedList
                                                    .add(chip.label);
                                              } else {
                                                _petSelectedList.removeWhere(
                                                    (label) =>
                                                        label == chip.label);
                                              }
                                            });
                                          },
                                          selectedColor: Style.buttonColor_pink,
                                          labelPadding: EdgeInsets.all(4),
                                          label: Text(chip.label.toString()),
                                          backgroundColor:
                                              Style.textFieldsColor_lightpink,
                                        ))
                                    .toList()),
                            SizedBox(
                              height: 15,
                            ),
                            (anotherPersonailty != null &&
                                        anotherPersonailty != "" &&
                                        _petSelectedList.contains("اخرى")) ||
                                    _petSelectedList.contains("اخرى")
                                ? addAnotherPer()
                                : Container(),
                            SizedBox(
                              height: 30,
                            ),
                            _isloading2
                                ? Center(
                                    child: Container(
                                        width: 40,
                                        height: 50,
                                        padding: EdgeInsets.only(bottom: 20),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color.fromARGB(
                                                      255, 155, 140, 181)),
                                          backgroundColor: Style.purpole,
                                        )),
                                  )
                                : Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    child: MyButton(
                                      color: Style.buttonColor_pink,
                                      title: "تحديث",
                                      onPeressed: () {
                                        try {
                                          bool isComplete = false;
                                          if (formState.currentState!
                                              .validate()) {
                                            if (_petSelectedList
                                                .contains("اخرى"))
                                              _petSelectedList[0] =
                                                  _personailty.text;
                                            else {
                                              _petSelectedList[0] = "";
                                              // _petSelectedList.remove("اخرى");
                                            }
                                            _petSelectedList.remove("اخرى");

                                            update();

                                            // if (_petSelectedList.length != 1) {
                                            //   isComplete = true;
                                            // }
                                            // if (isComplete) {
                                            //   if (_petSelectedList
                                            //       .contains("اخرى"))
                                            //     _petSelectedList[0] =
                                            //         _personailty.text;
                                            //   else {
                                            //     _petSelectedList[0] = "";
                                            //     // _petSelectedList.remove("اخرى");
                                            //   }

                                            //   _petSelectedList.remove("اخرى");

                                            //   print(_petSelectedList);
                                            //   update();
                                            // }
                                          } else {
                                            _showErrorDialog(
                                                "قم بتعبئة جميع الخانات الاجباريه ");
                                          }
                                        } catch (e) {}
                                      },
                                      minwidth: 500,
                                      circular: 0,
                                    ),
                                  )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ])),
    );
  }
}
