import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/adoption_request_info.dart';
import 'package:ewaa_application/screens/my_requests.dart';
import 'package:ewaa_application/style.dart';
import 'package:ewaa_application/widgets/bottom_nav.dart';
import 'package:ewaa_application/widgets/button.dart';
import 'package:ewaa_application/widgets/custom_app_bar.dart';
import 'package:ewaa_application/widgets/listView.dart';
import 'package:ewaa_application/widgets/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  static const String screenRoute = "notification_page";

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  getNotificationSource() {
    // Get all notifications sent to me from new to oldest
    return _firestore
        .collection("notifications")
        .where("to", arrayContains: _auth.currentUser!.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  updateNotificationsToSeen() {
    // and because the user open the notification page we will update status of all notfication that send to this user to be "seen"
    _firestore
        .collection("notifications")
        .where("to", arrayContains: _auth.currentUser!.uid)
        .where("status", isEqualTo: "unseen")
        .get()
        .then((notifications) {
      WriteBatch batch = _firestore.batch();
      for (var notification in notifications.docs) {
        batch.update(notification.reference, {"status": "seen"});
      }
      batch.commit();
    });
  }

// method to delete all notifaction that send to this user
  deleteAllNotifications() {
    _firestore
        .collection("notifications")
        .where("to", arrayContains: _auth.currentUser!.uid)
        .get()
        .then((notifications) {
      WriteBatch batch = _firestore.batch();
      for (var notification in notifications.docs) {
        batch.delete(notification.reference);
      }
      batch.commit();
    });
  }

//  delete specific notification
  deleteNotification(id) async {
    _firestore.collection("notifications").doc(id).delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateNotificationsToSeen();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar: getCustomAppBar(context),
      drawer: listView(),
      bottomNavigationBar: const BottomNav(
        selectedPage: NotificationsScreen.screenRoute,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSectionTitle(context, "الإشعارات"),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Container(
                    height: 30,
                    // button to delete all notfication send to this user
                    child: MyButton2(
                        color: Style.buttonColor_pink,
                        title: "إزالة الكل",
                        onPeressed: () {
                          deleteAllNotifications();
                        })),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getNotificationSource(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text("يوجد خطأ");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
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
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            "لا توجد إشعارات",
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
                    children: snapshot.data!.docs.map((notification) {
                      Timestamp createdAt = notification['createdAt'];
                      var createdAtDate = createdAt.toDate();
                      var datestr =
                          '${createdAtDate.year}-${createdAtDate.month}-${createdAtDate.day}';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Style.textFieldsColor_lightpink
                                .withOpacity(0.4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      datestr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Style.black,
                                        fontFamily: 'ElMessiri',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        // buuton to delete this notification
                                        deleteNotification(notification.id);
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Style.brown,
                                      ))
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  notification['content'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Style.black,
                                    fontFamily: 'ElMessiri',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 36,
                                  margin: const EdgeInsets.only(right: 80),
                                  child:
                                      notification["type"] != "request_rejected"
                                          ? MyButton2(
                                              color: Style.buttonColor_pink,
                                              title: "عرض طلب التبني",
                                              onPeressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AdoptionRequestInfo(
                                                      request_id: notification[
                                                          "request_id"],
                                                    ),
                                                  ),
                                                );
                                              })
                                          : const SizedBox(),
                                ),
                              ),
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
