import 'package:ewaa_application/screens/favouritesPage.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/screens/my_requests.dart';
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
      if (selectedPage == HomePage.screenRoute) return 0;
      if (selectedPage == MyRequests.screenRoute) return 1;
      if (selectedPage == FavouritesPage.screenRoute) return 2;
      return 0;
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "الرئيسية",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.handshake),
          label: "طلبات التبني",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "المفضلة",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active),
          label: "الإشعارات",
        ),
      ],
      onTap: (value) {
        if (0 == value) {
          Navigator.pushReplacementNamed(context, HomePage.screenRoute);
        } else if (1 == value) {
          if (_auth.currentUser == null)
            Navigator.pushReplacementNamed(context, Login.screenRoute);
          else
            Navigator.pushReplacementNamed(context, MyRequests.screenRoute);
        } else if (2 == value) {
          if (_auth.currentUser == null)
            Navigator.pushReplacementNamed(context, Login.screenRoute);
          else
            Navigator.pushReplacementNamed(context, FavouritesPage.screenRoute);
        } else if (3 == value) {
          // Navigator.pushReplacementNamed(context, .screenRoute);
        }
      },
    );
  }
}
