import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/adoption_request_info.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestsLog extends StatefulWidget {
  static const String screenRoute = "requests_log_page";
  const RequestsLog({Key? key}) : super(key: key);

  @override
  State<RequestsLog> createState() => _RequestsLogState();
}

class _RequestsLogState extends State<RequestsLog> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  double button_size = 40;
// the widget of satue of request
  Widget statusChip(String status) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: status == "قيد المعالجة"
              ? Colors.yellow
              : status == "مقبول"
                  ? Colors.green
                  : Colors.red,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Style.textFieldsColor_lightpink)),
      child: Center(
        child: Text(
          status,
          style: TextStyle(
              fontFamily: 'ElMessiri',
              color: status == "قيد المعالجة" ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  getRequestsList() {
    return _firestore
        .collection("adoption_requests")
        .where("adopter_id", isEqualTo: _auth.currentUser!.uid)
        .where("status", whereIn: ["مقبول", "مرفوض"])
        .orderBy("request_date", descending: true)
        .snapshots();
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

  Widget getContactControls(String status, String owner_id,
      [String request_id = ""]) {
    if (status == "مرفوض") {
      return const SizedBox();
    } else {
      Map<String, dynamic>? userdoc = Map();
      _firestore.collection("Users").doc(owner_id).get().then((value) {
        userdoc = value.data();
      });
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              width: button_size,
              height: button_size,
              decoration: BoxDecoration(
                  color: Style.buttonColor_pink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Style.textFieldsColor_lightpink)),
              child: IconButton(
                  onPressed: () {
                    _makePhoneCall(userdoc!["phoneNumber"]);
                  },
                  icon: Icon(
                    Icons.call,
                    color: Colors.white,
                  ))),
          Container(
              width: button_size,
              height: button_size,
              decoration: BoxDecoration(
                  color: Style.buttonColor_pink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Style.textFieldsColor_lightpink)),
              child: IconButton(
                  onPressed: () {
                    _sendEmail(userdoc!["email"]);
                  },
                  icon: Icon(
                    Icons.mail,
                    color: Colors.white,
                  )))
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar: getBasicAppBar(context),
      drawer: listView(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          buildSectionTitle(context, "العمليات السابقة"),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getRequestsList(),
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
                            "لاتوجد طلبات",
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
                      Timestamp request_date = document['request_date'];
                      var uplodedAtDate = request_date.toDate();
                      var date =
                          '${uplodedAtDate.year}-${uplodedAtDate.month}-${uplodedAtDate.day}';

                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Style.textFieldsColor_lightpink
                                .withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      document['pet_image'],
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child:
                                              statusChip(document["status"])),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              document['petName'] == ""
                                                  ? "بدون اسم"
                                                  : document['petName'],
                                              style: TextStyle(
                                                color: Style.black,
                                                fontFamily: 'ElMessiri',
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        date.toString(),
                                        style: TextStyle(
                                          color: Style.black,
                                          fontFamily: 'ElMessiri',
                                          fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          getContactControls(
                                              document["status"],
                                              document["owner_id"],
                                              document["request_id"]),
                                          Container(
                                            width: button_size,
                                            height: button_size,
                                            decoration: BoxDecoration(
                                                color: Style.purpole,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Style
                                                        .textFieldsColor_lightpink)),
                                            child: Center(
                                              child: IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AdoptionRequestInfo(
                                                          request_id: document[
                                                              "request_id"],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .arrow_forward_ios_outlined,
                                                    color: Colors.white,
                                                  )),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          )
        ],
      ),
    ));
  }
}
