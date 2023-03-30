import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/age_calculator.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoptionRequestInfo extends StatefulWidget {
  final String request_id;
  const AdoptionRequestInfo({Key? key, required this.request_id})
      : super(key: key);

  @override
  State<AdoptionRequestInfo> createState() => _AdoptionRequestInfoState();
}

class _AdoptionRequestInfoState extends State<AdoptionRequestInfo> {
  bool _isloading = true;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late var requestInfo;
  late var adopterInfo;
  late var petInfo;
  late var ownerInfo;
  late var isOwner = false;
  late int adopterAge = 0;

  getRequestInfo() async {
    await _firestore
        .collection("adoption_requests")
        .doc(widget.request_id)
        .get()
        .then((doc) {
      setState(() {
        requestInfo = doc;
      });
      getPetInfo();
    });
  }

  getPetInfo() async {
    await _firestore
        .collection("pets")
        .doc(requestInfo.get("pet_id"))
        .get()
        .then((doc) {
      if (!doc.exists) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "الحيوان غير موجود في قاعدة البيانات",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Style.textFieldsColor_lightpink,
            textColor: Style.purpole,
            fontSize: 16.0);
      } else
        setState(() {
          petInfo = doc;
          getOwnerInfo();
        });
    });
  }

  getOwnerInfo() async {
    await _firestore
        .collection("Users")
        .doc(requestInfo.get("owner_id"))
        .get()
        .then((doc) {
      setState(() {
        ownerInfo = doc;
        getAdopterInfo();
        if (_auth.currentUser!.uid == ownerInfo.get("id")) isOwner = true;
      });
    });
  }

  getAdopterInfo() async {
    await _firestore
        .collection("Users")
        .doc(requestInfo.get("adopter_id"))
        .get()
        .then((doc) {
      setState(() {
        adopterInfo = doc;
        getAdopterAge();
        _isloading = false;
      });
    });
  }

  getAdopterAge() {
    var birthdate = requestInfo.get("adopter_age");
    try {
      DateTime bdate = DateTime.parse(birthdate);
      setState(() {
        adopterAge = findAge(bdate);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRequestInfo();
  }

  void updateRequestStatus(String state) {
    _firestore
        .collection("adoption_requests")
        .doc(widget.request_id)
        .update({"status": state}).then((value) {
      if (state == "مرفوض") {
        getRequestInfo();
        var content = "تم رفض طلب تبني الحيوان " +
            requestInfo.get("petName") +
            " الذي أرسلته";
        var to = [requestInfo.get("adopter_id")];
        var type = "request_rejected";
        sendNotification(content, to, type);
      } else {
        updateOwner();
        var content = "تم قبول طلب تبني الحيوان " +
            requestInfo.get("petName") +
            " الذي أرسلته";
        var to = [requestInfo.get("adopter_id")];
        var type = "request_accepted";
        sendNotification(content, to, type);
      }
    });
  }

  void sendNotification(content, to, type) {
    //send notification
    Map<String, dynamic> notification = {};
    notification["content"] = content;
    notification["type"] = type;
    notification["to"] = to;
    notification["createdAt"] = FieldValue.serverTimestamp();
    notification["request_id"] = widget.request_id;
    notification["status"] = "unseen";
    FirebaseFirestore.instance.collection("notifications").add(notification);
  }

  void rejectOtherRequests() {
    _firestore
        .collection("adoption_requests")
        .where("pet_id", isEqualTo: petInfo["petId"])
        .where("status", isEqualTo: "قيد المعالجة")
        .get()
        .then((requests) {
      WriteBatch batch = _firestore.batch();
      var to = [];
      for (var request in requests.docs) {
        batch.update(request.reference, {"status": "مرفوض"});

        to.add(request.get("adopter_id"));
      }
      batch.commit().then((value) {
        //send notification
        var content = "تم رفض طلب تبني الحيوان " +
            requestInfo.get("petName") +
            " الذي أرسلته";
        var type = "request_rejected";
        sendNotification(content, to, type);
      });
    });
  }

  deletePetFromLiked(petId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .where("likedPets", arrayContains: petId)
        .get()
        .then((users) {
      for (var user in users.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(user.id)
            .update({"likedPets": FieldValue.arrayRemove(petId)});
      }
    });
  }

  void updateOwner() {
    _firestore.collection("pets").doc(requestInfo.get("pet_id")).update({
      "isAdopted": true,
      "old_owner": petInfo["ownerId"],
      "ownerId": requestInfo["adopter_id"]
    }).then((value) {
      rejectOtherRequests();

      ///
      deletePetFromLiked(requestInfo.get("pet_id"));
      Navigator.pushReplacementNamed(context, HomePage.screenRoute);
      Fluttertoast.showToast(
          msg: "تم قبول الطلب بنجاح ونقل ملكية الحيوان الى المتبني",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Style.textFieldsColor_lightpink,
          textColor: Style.purpole,
          fontSize: 16.0);
    });
  }

  void deleteRequest() {
    setState(() {
      _isloading = true;
    });
    _firestore
        .collection("adoption_requests")
        .doc(widget.request_id)
        .delete()
        .then((value) {
      Fluttertoast.showToast(
          msg: "تم إلغاء طلب التبني بنجاح",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Style.textFieldsColor_lightpink,
          textColor: Style.purpole,
          fontSize: 16.0);
      Navigator.pushReplacementNamed(context, HomePage.screenRoute);
      setState(() {
        _isloading = false;
      });
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String emailAddres) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddres,
    );
    await launchUrl(launchUri);
  }

  Widget getControlButtons() {
    if (isOwner) {
      if (requestInfo.get("status") == "قيد المعالجة") {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: MyButton2(
                    color: Colors.green,
                    title: "قبول",
                    onPeressed: () {
                      updateRequestStatus("مقبول");
                    })),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: MyButton2(
                    color: Colors.red,
                    title: "رفض",
                    onPeressed: () {
                      updateRequestStatus("مرفوض");
                    }))
          ],
        );
      } else if (requestInfo.get("status") == "مقبول") {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: MyButton2(
                  color: Style.buttonColor_pink,
                  title: "اتصال",
                  onPeressed: () {
                    _makePhoneCall(adopterInfo.get("phoneNumber").toString());
                  }),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: MyButton2(
                  color: Style.buttonColor_pink,
                  title: "مراسلة",
                  onPeressed: () {
                    _sendEmail(adopterInfo.get("email").toString());
                  }),
            )
          ],
        );
      } else {
        //------------------------------------------------------------------------------
        // return buildSectionTitle(context, "تم رفض الطلب");
        return Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15),
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: new BorderRadius.all(Radius.elliptical(2, 10)),
            ),
            child: Text(
              "تم رفض الطلب",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'ElMessiri',
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } else {
      if (requestInfo.get("status") == "قيد المعالجة") {
        return MyButton(
          color: Style.buttonColor_pink,
          title: "إلغاء طلب التبني",
          onPeressed: () {
            deleteRequest();
          },
          minwidth: 500,
          circular: 0,
        );
      } else if (requestInfo.get("status") == "مقبول") {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: MyButton2(
                    color: Style.buttonColor_pink,
                    title: "اتصال",
                    onPeressed: () {
                      _makePhoneCall(ownerInfo.get("phoneNumber").toString());
                    })),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: MyButton2(
                    color: Style.buttonColor_pink,
                    title: "مراسلة",
                    onPeressed: () {
                      _sendEmail(ownerInfo.get("email").toString());
                    }))
          ],
        );
      } else {
        return Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15),
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: new BorderRadius.all(Radius.elliptical(2, 10)),
            ),
            child: Text(
              "تم رفض الطلب",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'ElMessiri',
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: getBasicAppBar(context),
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
                : Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: Column(children: [
                      Expanded(
                          child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                            petInfo.get("image") != ""
                                ? Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height *
                                        0.27,
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                petInfo.get("image"),
                                              ))),
                                    ))
                                : Container(
                                    margin: EdgeInsets.only(
                                        bottom: 5, left: 26, right: 26),
                                    alignment: Alignment.center,
                                    height: 130,
                                    width: 200,
                                    child: Container(
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            AssetImage("images/profile.jpg"),
                                        backgroundColor: Colors.white,
                                      ),
                                    )),
                            SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(13),
                                decoration: new BoxDecoration(
                                  color: Style.textFieldsColor_lightpink
                                      .withOpacity(0.8),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.2),
                                      width: 2),
                                  borderRadius: new BorderRadius.all(
                                      Radius.elliptical(2, 10)),
                                ),
                                child: petInfo.get("petName") != ""
                                    ? Text(
                                        " معلومات المتقدم لطلب تبني " +
                                            petInfo.get("petName"),
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ElMessiri',
                                            color: Style.purpole))
                                    : Text(" معلومات المتقدم لطلب التبني ",
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ElMessiri',
                                            color: Style.purpole)),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                requestInfo.get("has_pet") == "لا"
                                    ? Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(20),
                                          decoration: new BoxDecoration(
                                            color: Style
                                                .textFieldsColor_lightpink
                                                .withOpacity(0.3),
                                            borderRadius: new BorderRadius.all(
                                                Radius.elliptical(2, 10)),
                                          ),
                                          child: Text(
                                            " ليس لديه حيوان أليف",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'ElMessiri',
                                                color: Style.purpole),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(20),
                                          decoration: new BoxDecoration(
                                            color: Style
                                                .textFieldsColor_lightpink
                                                .withOpacity(0.3),
                                            borderRadius: new BorderRadius.all(
                                                Radius.elliptical(2, 10)),
                                          ),
                                          child: Text(
                                            " لديه حيوان أليف",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'ElMessiri',
                                                color: Style.purpole),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(20),
                                    decoration: new BoxDecoration(
                                      color: Style.textFieldsColor_lightpink
                                          .withOpacity(0.3),
                                      borderRadius: new BorderRadius.all(
                                          Radius.elliptical(2, 10)),
                                    ),
                                    child: Text(
                                      requestInfo.get("job_state"),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'ElMessiri',
                                          color: Style.purpole),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //=====================================
                            SizedBox(
                              height: 12,
                            ),
                            //==================----------------------------------------
                            Row(
                              children: [
                                requestInfo.get("has_allergy") == "لا"
                                    ? Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(20),
                                          decoration: new BoxDecoration(
                                            color: Style
                                                .textFieldsColor_lightpink
                                                .withOpacity(0.3),
                                            borderRadius: new BorderRadius.all(
                                                Radius.elliptical(2, 10)),
                                          ),
                                          child: Text(
                                            "لا توجد حساسية",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'ElMessiri',
                                                color: Style.purpole),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(20),
                                          decoration: new BoxDecoration(
                                            color: Style
                                                .textFieldsColor_lightpink
                                                .withOpacity(0.3),
                                            borderRadius: new BorderRadius.all(
                                                Radius.elliptical(2, 10)),
                                          ),
                                          child: Text(
                                            "توجد حساسية",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'ElMessiri',
                                                color: Style.purpole),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(20),
                                    decoration: new BoxDecoration(
                                      color: Style.textFieldsColor_lightpink
                                          .withOpacity(0.3),
                                      borderRadius: new BorderRadius.all(
                                          Radius.elliptical(2, 10)),
                                    ),
                                    child: Text(
                                      "${adopterAge} سنة",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'ElMessiri',
                                          color: Style.purpole),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //============-----------------------------------------

                            SizedBox(
                              height: 12,
                            ),
                            Align(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(13),
                                decoration: new BoxDecoration(
                                  color: Style.textFieldsColor_lightpink
                                      .withOpacity(0.8),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.2),
                                      width: 2),
                                  borderRadius: new BorderRadius.all(
                                      Radius.elliptical(2, 10)),
                                ),
                                child: Text("اسباب الرغبة في تبني الحيوان",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'ElMessiri',
                                        color: Style.purpole)),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            requestInfo.get("adoption_reason") == ""
                                ? Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(20),
                                      decoration: new BoxDecoration(
                                        color: Style.textFieldsColor_lightpink
                                            .withOpacity(0.3),
                                        borderRadius: new BorderRadius.all(
                                            Radius.elliptical(2, 10)),
                                      ),
                                      child: Text(
                                        "الأسباب غير مذكورة",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'ElMessiri',
                                            color: Style.purpole),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(20),
                                      decoration: new BoxDecoration(
                                        color: Style.textFieldsColor_lightpink
                                            .withOpacity(0.1),
                                        borderRadius: new BorderRadius.all(
                                            Radius.elliptical(2, 10)),
                                      ),
                                      child: Text(
                                        requestInfo.get("adoption_reason"),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'ElMessiri',
                                            color: Style.purpole),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),

                            SizedBox(
                              height: 12,
                            ),

                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: getControlButtons(),
                            )
                          ]))
                    ]),
                  )));
  }
}
