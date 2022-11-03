import 'package:ewaa_application/screens/addP.dart';
import 'package:ewaa_application/screens/continuesAdd.dart';
import 'package:ewaa_application/screens/forget_passward.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/listPets.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/my_pets_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', ''), // English, no country code
      ],
      title: 'ايواء',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ElMessiri',
        textTheme: ThemeData.light().textTheme.copyWith(
              // يساعد اغير الستايل الديفولت
              headline5: TextStyle(
                color: Style.brown,
                fontSize: 60,
                fontFamily: 'ElMessiri',
              ),
              headline6: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.bold,
              ),
              headline1: TextStyle(
                color: Style.brown,
                fontSize: 23,
                fontFamily: 'ElMessiri',
              ),
              headline2: TextStyle(
                color: Style.brown,
                fontSize: 50,
                fontFamily: 'ElMessiri',
              ),
              headline3: TextStyle(
                color: Style.black,
                fontSize: 15,
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.bold,
              ),
              headline4: TextStyle(
                color: Style.purpole,
                fontSize: 26,
                fontFamily: 'ElMessiri',
              ),
            ),
      ),
      // احدد موديل الخط

      home: HomePage(),
      routes: {
        Register.screenRoute: (context) => Register(),
        Login.screenRoute: (context) => Login(),
        HomePage.screenRoute: (context) => HomePage(),
        ProfilePage.screenRoute: (context) => ProfilePage(),
        ListPetsPage.screenRoute: (context) => ListPetsPage(),
        ContinuesAdd.screenRoute: (context) => ContinuesAdd(),
        AddPets.screenRoute: (context) => AddPets(),
        ForgfetPassward.screenRoute: (context) => ForgfetPassward(),
        MyPetsPage.screenRoute: (context) => MyPetsPage(),
      },
    );
  }
}
