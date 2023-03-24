import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/adoption_request_info.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/bottom_nav.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRequests extends StatefulWidget {
  static const String screenRoute = "my_requests_page";

  String initType;
  // type of request by defult is in progress
  MyRequests({Key? key, this.initType = "الطلبات المرسلة"}) : super(key: key);

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  var _selectedType = "الطلبات المرسلة";
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  double button_size = 40;
  var statusList = [
    {'id': 1, 'state': "قيد المعالجة"},
    {'id': 2, 'state': "مقبول"},
    {'id': 3, 'state': "مرفوض"},
  ];
  // type of request by defult is in progress
  var _selectedStatusId = 1;
  var _selectedStatusLabel = "قيد المعالجة";

  Widget typeChip(String type) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
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

  Widget statusChip(String status) {
    if (_selectedType == "الطلبات المستقبلة") {
      return const SizedBox();
    }

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
    //  first we check if user select request that he/she send to adopt pet . then we retrive the all requests thst adopter id is equle to the id of active user and with state same as statue that active user select , get the request from newst to older
    if (_selectedType == "الطلبات المرسلة") {
      return _firestore
          .collection("adoption_requests")
          .where("adopter_id", isEqualTo: _auth.currentUser!.uid)
          .where("status", isEqualTo: _selectedStatusLabel)
          .orderBy("request_date", descending: true)
          .snapshots();
    } else {
      // if user select the request that he/she recive then  then we retrive the all requests thst owner  id is equle to the id of active user and with state same as statue that active user select , get the request from newst to older
      return _firestore
          .collection("adoption_requests")
          .where("owner_id", isEqualTo: _auth.currentUser!.uid)
          .where("status", isEqualTo: _selectedStatusLabel)
          .orderBy("request_date", descending: true)
          .snapshots();
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      // to open phone applicatio we set  scheme: 'tel'
      scheme: 'tel',
      // I set this number as the path where the phone application should open it
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
    } else if (status == "قيد المعالجة" &&
        _selectedType == "الطلبات المستقبلة") {
      return const SizedBox();
    } // for request I sent t and it is in progress, there is a red button to cancel the request if I wish
    else if (status == "قيد المعالجة" && _selectedType == "الطلبات المرسلة") {
      return Container(
        width: button_size,
        height: button_size,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Style.textFieldsColor_lightpink)),
        child: Center(
          child: IconButton(
              onPressed: () {
                // this method to cancel this request
                deleteRequest(request_id);
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
              )),
        ),
      );
    } else {
      Map<String, dynamic>? userdoc = Map();
      // get the information of owner or adopter of this request because the request is accepted
      _firestore.collection("Users").doc(owner_id).get().then((value) {
        // data of this document
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

  void deleteRequest(request_id) {
    //  This method receives the id of the request that the user wants to cancel, and then we delete that request from adoption_requests collection

    _firestore
        .collection("adoption_requests")
        .doc(request_id)
        .delete()
        .then((value) {
      //cancel notification
      _firestore.collection("notifications").doc(request_id).delete();

      Fluttertoast.showToast(
          msg: "تم إلغاء طلب التبني بنجاح",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Style.textFieldsColor_lightpink,
          textColor: Style.purpole,
          fontSize: 16.0);
    });
  }

  Widget outgoing_request(document) {
    // get the data of thos request
    Timestamp request_date = document['request_date'];
    var uplodedAtDate = request_date.toDate();
    var date =
        '${uplodedAtDate.year}-${uplodedAtDate.month}-${uplodedAtDate.day}';

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Style.textFieldsColor_lightpink.withOpacity(0.4),
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
                        child: statusChip(document["status"])),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // If the owner has accepted our request, then we can get the owner's contact information via the method getContactControls that why we send to this method the sataue of this request
                        getContactControls(document["status"],
                            document["owner_id"], document["request_id"]),
                        Container(
                          width: button_size,
                          height: button_size,
                          decoration: BoxDecoration(
                              color: Style.purpole,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Style.textFieldsColor_lightpink)),
                          child: Center(
                            child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdoptionRequestInfo(
                                        request_id: document["request_id"],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_forward_ios_outlined,
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
  }
  // request I recive

  Widget incoming_request(document) {
    Timestamp request_date = document['request_date'];
    var uplodedAtDate = request_date.toDate();
    var date =
        '${uplodedAtDate.year}-${uplodedAtDate.month}-${uplodedAtDate.day}';
    print(document["request_id"]);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Style.textFieldsColor_lightpink.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  document['petName'] == ""
                                      ? "بدون اسم"
                                      : document['petName'],
                                  style: TextStyle(
                                    color: Style.black,
                                    fontFamily: 'ElMessiri',
                                    fontSize: 26,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  date.toString(),
                                  style: TextStyle(
                                    color: Style.black,
                                    fontFamily: 'ElMessiri',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  document['adoption_reason'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Style.black,
                                    fontFamily: 'ElMessiri',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Container(
                            width: button_size,
                            height: button_size,
                            decoration: BoxDecoration(
                                color: Style.purpole,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Style.textFieldsColor_lightpink)),
                            child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdoptionRequestInfo(
                                          request_id: document["request_id"],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // method to get contact information , we send tha status of request to ensure that contact doest not appear unless I accept the request , and the adopter id who send thois request
                    getContactControls(document["status"],
                        document["adopter_id"], document["request_id"]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedType = widget.initType;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar: getCustomAppBar(context),
      drawer: listView(),
      bottomNavigationBar: BottomNav(
        selectedPage: MyRequests.screenRoute,
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: typeChip("الطلبات المرسلة")),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: typeChip("الطلبات المستقبلة")),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: FormHelper.dropDownWidget(
              context,
              "الحالة",
              // this id of type of request that was selected
              this._selectedStatusId,
              this.statusList,
              (id) {
                setState(() {
                  // get the state of this id , for example when user from drodown menu select مقبول then the value of this option is 2 to get state of thsi value , we will look for the statusList to get the state that have this id
                  _selectedStatusLabel = statusList
                      .where((state) => state["id"].toString() == id.toString())
                      .first["state"] as String;
                });
              },
              (value) {
                if (value == null) {
                  return " قم بالاختيار";
                }

                return null;
              },
              // from statusList the value of the opton is id and label is state of request
              optionValue: "id",
              optionLabel: "state",
              borderColor: Style.gray,
              borderFocusColor: Style.purpole,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          buildSectionTitle(context, "طلبات التبني"),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // get requests list
              stream: getRequestsList(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // if there an error then there a text display to the screen
                if (snapshot.hasError) return Text("يوجد خطأ");
                // if it is watting then there a circular progress indicator appear
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                  // if there no reuest of selected type then we will display a message to indicate there no request of this type
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
                  // if there a request then:
                  return ListView(
                    scrollDirection: Axis.vertical,
                    children: snapshot.data!.docs.map((document) {
                      // The first thing we will do is check the selected type that the user has selected, and if the request he/she has selected is the one the user sent, we call the method outgoing_request, and we send the document to it.
                      return _selectedType == "الطلبات المرسلة"
                          ? outgoing_request(document)
                          // else  we call incoming_request to return the request that this user receive
                          : incoming_request(document);
                    }).toList(),
                  );
                }
              },
            ),
          )
        ],
        // kkk
      ),
    ));
  }
}
