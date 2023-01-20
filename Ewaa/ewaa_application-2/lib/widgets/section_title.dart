//--------------section ------------------------------------
import 'package:ewaa_application/style.dart';
import 'package:flutter/material.dart';

Widget buildSectionTitle(BuildContext context, String title,
    {double fontSize = 24}) {
  return Container(
    margin: EdgeInsets.only(left: 26, right: 26),
    alignment: Alignment.topRight,
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Style.black,
        fontSize: fontSize,
        fontFamily: 'ElMessiri',
      ),
    ),
  );
}
