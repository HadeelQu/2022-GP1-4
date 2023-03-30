import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/fieldAdd.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:uuid/uuid.dart';
import 'package:ewaa_application/widgets/helper.dart';

class AdoptionForm extends StatefulWidget {
  bool after_login = false;
  // final String petId;
  // final String ownerId;
  static const String screenRoute = "adoption_form_page";

  AdoptionForm({this.after_login: false});

  @override
  State<AdoptionForm> createState() => _AdoptionFormState();
}

class _AdoptionFormState extends State<AdoptionForm> {
  GlobalKey<FormState> formState = new GlobalKey<FormState>();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _adoptReasonController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late var petName;
  late var petImage;
  var hasApet;
  var hasAllergy;
  var jobState;
  var selectedJobId;
  List<dynamic> jobList = [];

  bool _isloading = false;

  late var adoption_info;

  save() async {
    var uid = _auth.currentUser!.uid;
    var new_adoption_info = {
      "adopter_id": uid,
      "has_pet": hasApet,
      "has_allergy": hasAllergy,
      "job_state": jobState,
      "adopter_age": _ageController.text,
      "adoption_reason": _adoptReasonController.text
    };

    setState(() {
      _isloading = true;
    });

    await _firestore
        .collection("Users")
        .doc(uid)
        .update({"adoption_info": new_adoption_info}).then((value) {
      //update pet name i all request
      var batch = FirebaseFirestore.instance.batch();

      FirebaseFirestore.instance
          .collection("adoption_requests")
          .where("adopter_id", isEqualTo: uid)
          .get()
          .then((requests) {
        for (var request in requests.docs) {
          batch.update(request.reference, new_adoption_info);
        }
        batch.commit();
      });

      Fluttertoast.showToast(
          msg: "تم تحديث المعلومات بنجاح",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Style.textFieldsColor_lightpink,
          textColor: Style.purpole,
          fontSize: 16.0);
      setState(() {
        _isloading = false;
      });
      if (widget.after_login) {
        Navigator.pushReplacementNamed(context, HomePage.screenRoute);
      } else {
        Navigator.pop(context);
      }
    }).catchError((e) {
      setState(() {
        _isloading = false;
      });
    });
  }

  getAdoptionInfo() async {
    var uid = _auth.currentUser!.uid;
    setState(() {
      _isloading = true;
    });
    await _firestore.collection("Users").doc(uid).get().then((userInfo) {
      setState(() {
        _isloading = false;

        if (userInfo.get("adoption_info") != null) {
          adoption_info = userInfo.get("adoption_info");
          hasApet = adoption_info["has_pet"];
          hasAllergy = adoption_info["has_allergy"];
          selectedJobId = this
              .jobList
              .where((job) => job["role"] == adoption_info["job_state"])
              .first["id"];
          jobState = adoption_info["job_state"];
          _ageController.text = adoption_info["adopter_age"];
          _adoptReasonController.text = adoption_info["adoption_reason"];
        }
      });
    }).catchError((e) {
      setState(() {
        _isloading = false;
      });
    });
  }

  // getPetInfo() async {
  //   setState(() {
  //     _isloading = true;
  //   });
  //   await _firestore.collection("pets").doc(widget.petId).get().then((doc) {
  //     print(doc);
  //     setState(() {
  //       petName = doc.get("petName");
  //       petImage = doc.get("image");
  //       _isloading = false;
  //     });
  //   });
  // }

  // send() async {
  //   try {
  //     if (_auth != null) {
  //       User siginUser = _auth.currentUser!;
  //       setState(() {
  //         _isloading = true;
  //       });
  //       final adopterId = siginUser.uid;
  //       final request_id = Uuid().v4();
  //       print(adopterId);
  //
  //       await _firestore.collection("adoption_requests").doc(request_id).set({
  //         "request_id": request_id,
  //         "petName": petName,
  //         "adopter_id": adopterId,
  //         "owner_id": widget.ownerId,
  //         "has_pet": hasApet,
  //         "pet_id": widget.petId,
  //         "has_allergy": hasAllergy,
  //         "job_state": jobState,
  //         "adopter_age": _ageController.text,
  //         "adoption_reason": _adoptReasonController.text,
  //         "request_date": FieldValue.serverTimestamp(),

  //         "pet_image": petImage,
  //         "status": "قيد المعالجة"
  //       }).then((value) {
  //         Fluttertoast.showToast(
  //             msg: "تم إرسال طلب التبني بنجاح",
  //             toastLength: Toast.LENGTH_LONG,
  //             gravity: ToastGravity.CENTER,
  //             timeInSecForIosWeb: 2,
  //             backgroundColor: Style.textFieldsColor_lightpink,
  //             textColor: Style.purpole,
  //             fontSize: 16.0);
  //         Navigator.pushNamed(context, HomePage.screenRoute);
  //         setState(() {
  //           _isloading = false;
  //         });
  //       }).catchError((e) {
  //         print("eeeeeeeeeeeeee");
  //         print(e);
  //         setState(() {
  //           _isloading = false;
  //         });
  //       });
  //     }
  //   } catch (error) {
  //     print(error.toString());
  //     print("error to add");
  //
  //     setState(() {
  //       _isloading = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getPetInfo();
    getAdoptionInfo();
    this.jobList = [
      {"id": 1, "role": "طالب"}, //نتاكد
      {"id": 2, "role": "موظف "},
      {"id": 3, "role": 'غير ذلك'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: getProfilePageAppBar(context),
      drawer: listView(),
      body: _isloading
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
          : Column(
              children: [
                Expanded(
                    child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    buildSectionTitle(context, "المعلومات اللازمة للتبني"),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                        key: formState,
                        child: Column(
                          children: [
                            buildSectionTitle(context, "هل لديك حيوان اليف؟",
                                fontSize: 16),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 25,
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
                                      groupValue: hasApet,
                                      title: const Text("نعم"),
                                      selected: hasApet == "نعم",
                                      selectedTileColor: Colors.purple.shade50,
                                      onChanged: (value) {
                                        setState(() {
                                          hasApet = value;
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
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      value: "لا",
                                      groupValue: hasApet,
                                      selected: hasApet == "لا",
                                      selectedTileColor: Colors.purple.shade50,
                                      title: const Text("لا"),
                                      onChanged: (value) {
                                        setState(() {
                                          hasApet = value;
                                        });
                                      }),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            buildSectionTitle(context,
                                "هل لديك أو لدى أحد أفراد عائلتك حساسية من الحيوانات الأليفة؟",
                                fontSize: 16),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 25,
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
                                      selectedTileColor: Colors.purple.shade50,
                                      groupValue: hasAllergy,
                                      title: const Text("نعم"),
                                      selected: hasAllergy == "نعم",
                                      onChanged: (value) {
                                        setState(() {
                                          hasAllergy = value;
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
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      value: "لا",
                                      selectedTileColor: Colors.purple.shade50,
                                      groupValue: hasAllergy,
                                      title: const Text("لا"),
                                      selected: hasAllergy == "لا",
                                      onChanged: (value) {
                                        setState(() {
                                          hasAllergy = value;
                                        });
                                      }),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            buildSectionTitle(context, "حالتك الوظيفية:",
                                fontSize: 16),
                            SizedBox(
                              height: 15,
                            ),
                            FormHelper.dropDownWidget(
                              context,
                              "الحالة",
                              this.selectedJobId,
                              this.jobList,
                              (id) {
                                setState(() {
                                  print(id);

                                  jobState = jobList
                                      .where((job) =>
                                          job["id"].toString() == id.toString())
                                      .first["role"];
                                });
                                print(jobState);
                              },
                              (value) {
                                if (value == null) {
                                  return " قم بالاختيار";
                                }

                                return null;
                              },
                              optionValue: "id",
                              optionLabel: "role",
                              borderColor: Style.gray,
                              borderFocusColor: Style.purpole,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            buildSectionTitle(context, "تاريخ الميلاد",
                                fontSize: 16),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: Container(
                                  padding: EdgeInsets.all(0),
                                  height: 70,
                                  child: Center(
                                      child: TextField(
                                    controller: _ageController,
                                    //editing controller of this TextField
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Style.purpole),
                                        borderRadius:
                                            BorderRadius.circular(25.7),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                        borderRadius:
                                            BorderRadius.circular(25.7),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Style.purpole),
                                      filled: true,
                                      fillColor:
                                          Style.textFieldsColor_lightpink,
                                      focusColor: Style.buttonColor_pink,
                                      icon: Icon(
                                        Icons.calendar_today,
                                        color: Style.purpole,
                                      ),
                                      //icon of text field
                                      //label text of field
                                    ),
                                    readOnly: true,
                                    //set it true, so that user will not able to edit text
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          builder: (context, child) {
                                            return Theme(
                                              child: child!,
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Style
                                                      .textFieldsColor_lightpink,
                                                  // <-- SEE HERE
                                                  onPrimary: Style.purpole,
                                                  // <-- SEE HERE
                                                  onSurface: Style
                                                      .brown, // <-- SEE HERE
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Style
                                                        .purpole, // button text color
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950),
                                          //DateTime.now() - not to allow to choose before today.
                                          lastDate: DateTime.now());
                                      if (pickedDate != null) {
                                        print(
                                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                        print(
                                            formattedDate); //formatted date output using intl package =>  2021-03-16
                                        setState(() {
                                          _ageController.text =
                                              formattedDate; //set output date to TextField value.
                                        });
                                      } else {}
                                    },
                                  ))),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            buildSectionTitle(context, "ماسبب رغبتك في التبني",
                                fontSize: 16),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: FileldsAdd2(
                                "",
                                _adoptReasonController,
                                TextInputType.text,
                                null,
                                5,
                                null,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              child: MyButton(
                                color: Style.buttonColor_pink,
                                title: "حفظ",
                                onPeressed: () {
                                  if (formState.currentState!.validate()) {
                                    if (hasAllergy == null ||
                                        hasApet == null ||
                                        jobState == null ||
                                        _ageController.text.isEmpty) {
                                      showErrorDialog(
                                          "قم بتعبئة حميع المعلومات ", context);
                                    } else {
                                      save();
                                    }
                                  } else {
                                    showErrorDialog(
                                        "قم بتعبئة جميع المعلومات", context);
                                  }
                                },
                                minwidth: 500,
                                circular: 0,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            widget.after_login
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: MyButton(
                                      color: Style.buttonColor_pink,
                                      title: "تخطي",
                                      onPeressed: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            HomePage.screenRoute,
                                            (route) => route.isFirst);
                                      },
                                      minwidth: 500,
                                      circular: 0,
                                    ),
                                  )
                                : SizedBox(
                                    height: 10,
                                  ),
                          ],
                        ))
                  ],
                ))
              ],
            ),
    ));
  }
}
