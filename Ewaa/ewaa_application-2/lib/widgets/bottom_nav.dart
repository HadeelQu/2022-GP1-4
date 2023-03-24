import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewaa_application/screens/favouritesPage.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/screens/my_requests.dart';
import 'package:ewaa_application/screens/notifications_screen.dart';
import 'package:ewaa_application/screens/requests_log.dart';
import 'package:ewaa_application/screens/search.dart';
import 'package:ewaa_application/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, this.selectedPage = HomePage.screenRoute});
  final String selectedPage;

  @override
  Widget build(BuildContext context) {
    var _auth = FirebaseAuth.instance;

    int getSelectedIndex() {
      if (selectedPage == HomePage.screenRoute) {
        return 0;
      }
      if (selectedPage == MyRequests.screenRoute) {
        return 1;
      }
      if (selectedPage == FavouritesPage.screenRoute) {
        return 2;
      }
      if (selectedPage == NotificationsScreen.screenRoute) {
        return 3;
      }
      return 0;
    }

// get all notfication that user does not seen
    getNewNotifications() {
      return FirebaseFirestore.instance
          .collection("notifications")
          .where("to", arrayContains: _auth.currentUser!.uid)
          .where("status", isEqualTo: "unseen")
          .snapshots();
    }

    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(238, 252, 249, 249),
      currentIndex: getSelectedIndex(),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedItemColor:
          Style.buttonColor_pink, // const Color.fromARGB(189, 116, 115, 115),
      unselectedItemColor: const Color.fromARGB(189, 116, 115, 115),
      unselectedLabelStyle: const TextStyle(fontFamily: "ElMessiri"),
      selectedLabelStyle: const TextStyle(fontFamily: "ElMessiri"),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "الرئيسية",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.handshake),
          label: "طلبات التبني",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "المفضلة",
        ),
        BottomNavigationBarItem(
          icon: _auth.currentUser == null
              ? const Icon(Icons.notifications)
              : StreamBuilder<QuerySnapshot>(
                  stream: getNewNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // There is no notification that the user does not see, so the notification icon does not turn red if there is no notification 
                      if (snapshot.data!.docs.isEmpty) {
                        return const Icon(Icons.notifications);
                      } else {
                        // The notification icon turns red when a user has not seen a notification, and the number of unseen notifications is displayed. 
                        return Stack(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Colors.red,
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  snapshot.data!.docs.length.toString(),
                                  style: const TextStyle(
                                      fontSize: 8, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    } else {
                      return const Icon(Icons.notifications);
                    }
                  },
                ),
          label: "الإشعارات",
        ),
      ],
      onTap: (value) {
        if (0 == value) {
          Navigator.pushReplacementNamed(context, HomePage.screenRoute);
        } else if (1 == value) {
          if (_auth.currentUser == null) {
            Navigator.pushReplacementNamed(context, Login.screenRoute);
          } else {
            Navigator.pushReplacementNamed(context, MyRequests.screenRoute);
          }
        } else if (2 == value) {
          if (_auth.currentUser == null) {
            Navigator.pushReplacementNamed(context, Login.screenRoute);
          } else {
            Navigator.pushReplacementNamed(context, FavouritesPage.screenRoute);
          }
        } else if (3 == value) {
          if (_auth.currentUser == null) {
            Navigator.pushReplacementNamed(context, Login.screenRoute);
          } else {
            Navigator.pushReplacementNamed(
                context, NotificationsScreen.screenRoute);
          }
        }
      },
    );
  }
}
