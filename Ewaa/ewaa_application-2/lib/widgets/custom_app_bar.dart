import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:flutter/material.dart';

import '../screens/home.dart';

AppBar getCustomAppBar(BuildContext context) {
  var _auth = FirebaseAuth.instance;
  return AppBar(
    backgroundColor: Colors.white,
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
              Navigator.pushNamed(context, Login.screenRoute);
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
  );
}

AppBar getProfilePageAppBar(BuildContext context) {
  return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Style.black, size: 28),
      toolbarHeight: 75,
      title: Row(
        children: [
          SizedBox(
            width: 83,
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
              Navigator.pushReplacementNamed(context, HomePage.screenRoute);
            }),
      ]);
}

AppBar getBasicAppBar(BuildContext context) {
  var _auth = FirebaseAuth.instance;
  return AppBar(
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
                Navigator.pushNamed(context, Login.screenRoute);
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
            icon: const Icon(
              Icons.arrow_forward_sharp,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ]);
}
